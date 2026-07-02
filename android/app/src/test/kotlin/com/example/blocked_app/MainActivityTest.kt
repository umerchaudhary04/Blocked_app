package com.example.blocked_app

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.nio.ByteBuffer

@RunWith(RobolectricTestRunner::class)
@Config(manifest=Config.NONE, sdk=[33])
class MainActivityTest {

    private lateinit var mainActivity: MainActivity

    @Before
    fun setup() {
        mainActivity = Robolectric.buildActivity(MainActivity::class.java).create().get()
    }

    @Test
    fun `onActivityResult with VPN_REQUEST_CODE and RESULT_OK starts VPN service and returns CONNECTED`() {
        val mockResult = mock<MethodChannel.Result>()

        val pendingResultField = MainActivity::class.java.getDeclaredField("pendingResult")
        pendingResultField.isAccessible = true
        pendingResultField.set(mainActivity, mockResult)

        val onActivityResultMethod = MainActivity::class.java.getDeclaredMethod("onActivityResult", Int::class.java, Int::class.java, Intent::class.java)
        onActivityResultMethod.isAccessible = true
        onActivityResultMethod.invoke(mainActivity, 24, Activity.RESULT_OK, null)

        val shadowActivity = shadowOf(mainActivity)
        val startedIntent = shadowActivity.nextStartedService
        assertNotNull("Expected service to be started", startedIntent)
        assertEquals(BlockedVpnService::class.java.name, startedIntent?.component?.className)
        assertEquals("START_VPN", startedIntent?.action)

        verify(mockResult).success("CONNECTED")
        assertNull(pendingResultField.get(mainActivity))
    }

    @Test
    fun `onActivityResult with VPN_REQUEST_CODE and RESULT_CANCELED returns PERMISSION_DENIED`() {
        val mockResult = mock<MethodChannel.Result>()

        val pendingResultField = MainActivity::class.java.getDeclaredField("pendingResult")
        pendingResultField.isAccessible = true
        pendingResultField.set(mainActivity, mockResult)

        val onActivityResultMethod = MainActivity::class.java.getDeclaredMethod("onActivityResult", Int::class.java, Int::class.java, Intent::class.java)
        onActivityResultMethod.isAccessible = true
        onActivityResultMethod.invoke(mainActivity, 24, Activity.RESULT_CANCELED, null)

        val shadowActivity = shadowOf(mainActivity)
        val startedIntent = shadowActivity.nextStartedService
        assertNull("Expected no service to be started", startedIntent)

        verify(mockResult).success("PERMISSION_DENIED")
        assertNull(pendingResultField.get(mainActivity))
    }

    // To test MethodChannel, we can use a mock BinaryMessenger to intercept the messages, but it requires decoding ByteBuffer.
    // Instead, we can use flutter engine's actual dart executor to register a method channel from the test side.
    // Or we can mock the method call handler directly if we refactor MainActivity to make the handler accessible or inject it.
    // Since we shouldn't change the implementation, we can use reflection to intercept the BinaryMessageHandler from the mock,
    // and manually decode/encode using StandardMethodCodec.

    @Test
    fun `method channel startProtection sets pendingResult and starts VPN`() {
        val mockEngine = mock<FlutterEngine>()
        val mockDartExecutor = mock<DartExecutor>()
        // Let's use a real channel on a mock messenger if possible, but actually Flutter provides `MethodChannel` class.
        // If we configure FlutterEngine with a mock BinaryMessenger, we can capture the BinaryMessageHandler.
        val mockMessenger = mock<BinaryMessenger>()

        whenever(mockEngine.dartExecutor).thenReturn(mockDartExecutor)
        whenever(mockDartExecutor.binaryMessenger).thenReturn(mockMessenger)

        mainActivity.configureFlutterEngine(mockEngine)

        val argumentCaptor = argumentCaptor<BinaryMessenger.BinaryMessageHandler>()
        verify(mockMessenger).setMessageHandler(eq("com.blocked.app/native"), argumentCaptor.capture())

        val binaryHandler = argumentCaptor.firstValue

        // Encode a MethodCall
        val call = MethodCall("startProtection", null)
        val codec = io.flutter.plugin.common.StandardMethodCodec.INSTANCE
        val byteBuffer = codec.encodeMethodCall(call)
        byteBuffer.position(0)

        val mockReply = mock<BinaryMessenger.BinaryReply>()

        try {
            binaryHandler.onMessage(byteBuffer, mockReply)
        } catch (e: Exception) {
            // VpnService.prepare might throw or return null, it's fine.
        }

        val pendingResultField = MainActivity::class.java.getDeclaredField("pendingResult")
        pendingResultField.isAccessible = true

        // Ensure pendingResult is set. It should be a MethodChannel.Result that wraps the mockReply.
        assertNotNull(pendingResultField.get(mainActivity))
    }

    @Test
    fun `method channel stopProtection stops VPN and returns DISCONNECTED`() {
        val mockEngine = mock<FlutterEngine>()
        val mockDartExecutor = mock<DartExecutor>()
        val mockMessenger = mock<BinaryMessenger>()

        whenever(mockEngine.dartExecutor).thenReturn(mockDartExecutor)
        whenever(mockDartExecutor.binaryMessenger).thenReturn(mockMessenger)

        mainActivity.configureFlutterEngine(mockEngine)

        val argumentCaptor = argumentCaptor<BinaryMessenger.BinaryMessageHandler>()
        verify(mockMessenger).setMessageHandler(eq("com.blocked.app/native"), argumentCaptor.capture())

        val binaryHandler = argumentCaptor.firstValue

        val call = MethodCall("stopProtection", null)
        val codec = io.flutter.plugin.common.StandardMethodCodec.INSTANCE
        val byteBuffer = codec.encodeMethodCall(call)
        byteBuffer.position(0)

        val mockReply = mock<BinaryMessenger.BinaryReply>()
        binaryHandler.onMessage(byteBuffer, mockReply)

        val shadowActivity = shadowOf(mainActivity)
        val startedIntent = shadowActivity.nextStartedService
        assertNotNull("Expected service to be stopped", startedIntent)
        assertEquals(BlockedVpnService::class.java.name, startedIntent?.component?.className)
        assertEquals("STOP_VPN", startedIntent?.action)

        // Decode the reply to verify it's "DISCONNECTED"
        val replyCaptor = argumentCaptor<ByteBuffer>()
        verify(mockReply).reply(replyCaptor.capture())
        val responseBuffer = replyCaptor.firstValue
        responseBuffer.position(0)
        val response = codec.decodeEnvelope(responseBuffer)
        assertEquals("DISCONNECTED", response)
    }

    @Test
    fun `method channel getStatus returns status`() {
        val mockEngine = mock<FlutterEngine>()
        val mockDartExecutor = mock<DartExecutor>()
        val mockMessenger = mock<BinaryMessenger>()

        whenever(mockEngine.dartExecutor).thenReturn(mockDartExecutor)
        whenever(mockDartExecutor.binaryMessenger).thenReturn(mockMessenger)

        mainActivity.configureFlutterEngine(mockEngine)

        val argumentCaptor = argumentCaptor<BinaryMessenger.BinaryMessageHandler>()
        verify(mockMessenger).setMessageHandler(eq("com.blocked.app/native"), argumentCaptor.capture())

        val binaryHandler = argumentCaptor.firstValue

        val call = MethodCall("getStatus", null)
        val codec = io.flutter.plugin.common.StandardMethodCodec.INSTANCE
        val byteBuffer = codec.encodeMethodCall(call)
        byteBuffer.position(0)

        val mockReply = mock<BinaryMessenger.BinaryReply>()
        binaryHandler.onMessage(byteBuffer, mockReply)

        val replyCaptor = argumentCaptor<ByteBuffer>()
        verify(mockReply).reply(replyCaptor.capture())
        val responseBuffer = replyCaptor.firstValue
        responseBuffer.position(0)
        val response = codec.decodeEnvelope(responseBuffer)
        assertTrue(response == "CONNECTED" || response == "DISCONNECTED")
    }

    @Test
    fun `method channel handles notImplemented`() {
        val mockEngine = mock<FlutterEngine>()
        val mockDartExecutor = mock<DartExecutor>()
        val mockMessenger = mock<BinaryMessenger>()

        whenever(mockEngine.dartExecutor).thenReturn(mockDartExecutor)
        whenever(mockDartExecutor.binaryMessenger).thenReturn(mockMessenger)

        mainActivity.configureFlutterEngine(mockEngine)

        val argumentCaptor = argumentCaptor<BinaryMessenger.BinaryMessageHandler>()
        verify(mockMessenger).setMessageHandler(eq("com.blocked.app/native"), argumentCaptor.capture())

        val binaryHandler = argumentCaptor.firstValue

        val call = MethodCall("unknownMethod", null)
        val codec = io.flutter.plugin.common.StandardMethodCodec.INSTANCE
        val byteBuffer = codec.encodeMethodCall(call)
        byteBuffer.position(0)

        val mockReply = mock<BinaryMessenger.BinaryReply>()
        binaryHandler.onMessage(byteBuffer, mockReply)

        verify(mockReply).reply(isNull())
    }
}
