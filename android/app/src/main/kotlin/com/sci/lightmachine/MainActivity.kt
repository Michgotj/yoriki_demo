package com.sci.lightmachine
import android.util.Log

import android.view.KeyCharacterMap
import android.view.KeyEvent
import android.view.inputmethod.BaseInputConnection
import android.view.inputmethod.InputConnection
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.yoriki.lightmachine/general"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result
            ->     "simulateKeyPress" -> {
                    val res = simulateKeyPress(call.arguments)
                    result.success(res)
                }
            if (call.method == "simulateKeyPress") {
                val res = simulateKeyPress(call.arguments)
                result.success(res);
            } else {
                result.notImplemented()
            }
        }
    }

    private fun simulateKeyPress(arguments: Any?): Boolean {
        val map = arguments as Map<*, *>
        val text = (map["text"] as String).trim()
        val type = map["type"] as Int
        if (type == 0) {
            return simulateKeyPress0(text);
        } else if(type == 1) {
            return simulateKeyPress1(text);
        }
        return simulateKeyPress1(text);
    }

    // Progressive simulation
    private fun simulateKeyPress0(input: String): Boolean {
        try {
            val activity: MainActivity = this
            val inputConnection = BaseInputConnection(
                activity.window.decorView.rootView,
                true
            )
            val szRes: CharArray = input.toCharArray()
            val charMap: KeyCharacterMap = KeyCharacterMap.load(KeyCharacterMap.VIRTUAL_KEYBOARD)
            val events = charMap.getEvents(szRes)
            for (event in events) {
                inputConnection.sendKeyEvent(event)
            }
            return true;
        } catch (e: Throwable) {
            return false;
        }
    }

    // Simple simulation
    private fun simulateKeyPress1(inputText: String): Boolean {
        try {
            val activity: MainActivity = this
            val inputConnection = BaseInputConnection(
                activity.window.decorView.rootView,
                true
            )
            val input = inputText.lowercase()
            for (char in input) {
                val code = getKeyCode(char.toString())
                simulateKeyEvent(inputConnection, code)
            }
            return true;
        } catch (e: Throwable) {
            return false;
        }
    }

    private fun simulateKeyEvent(inputConnection: BaseInputConnection, key: Int) {
        val downEvent = KeyEvent(KeyEvent.ACTION_DOWN, key)
        inputConnection.sendKeyEvent(downEvent)
        val upEvent = KeyEvent(KeyEvent.ACTION_UP, key)
        inputConnection.sendKeyEvent(upEvent)
    }

    private fun getKeyCode(char: String): Int {
        when (char) {
            "0" -> return KeyEvent.KEYCODE_0
            "1" -> return KeyEvent.KEYCODE_1
            "2" -> return KeyEvent.KEYCODE_2
            "3" -> return KeyEvent.KEYCODE_3
            "4" -> return KeyEvent.KEYCODE_4
            "5" -> return KeyEvent.KEYCODE_5
            "6" -> return KeyEvent.KEYCODE_6
            "7" -> return KeyEvent.KEYCODE_7
            "8" -> return KeyEvent.KEYCODE_8
            "9" -> return KeyEvent.KEYCODE_9
            "a" -> return KeyEvent.KEYCODE_A
            "b" -> return KeyEvent.KEYCODE_B
            "c" -> return KeyEvent.KEYCODE_C
            "d" -> return KeyEvent.KEYCODE_D
            "e" -> return KeyEvent.KEYCODE_E
            "f" -> return KeyEvent.KEYCODE_F
            "g" -> return KeyEvent.KEYCODE_G
            "h" -> return KeyEvent.KEYCODE_H
            "i" -> return KeyEvent.KEYCODE_I
            "j" -> return KeyEvent.KEYCODE_J
            "k" -> return KeyEvent.KEYCODE_K
            "l" -> return KeyEvent.KEYCODE_L
            "m" -> return KeyEvent.KEYCODE_M
            "n" -> return KeyEvent.KEYCODE_N
            "o" -> return KeyEvent.KEYCODE_O
            "p" -> return KeyEvent.KEYCODE_P
            "q" -> return KeyEvent.KEYCODE_Q
            "r" -> return KeyEvent.KEYCODE_R
            "s" -> return KeyEvent.KEYCODE_S
            "t" -> return KeyEvent.KEYCODE_T
            "u" -> return KeyEvent.KEYCODE_U
            "v" -> return KeyEvent.KEYCODE_V
            "w" -> return KeyEvent.KEYCODE_W
            "x" -> return KeyEvent.KEYCODE_X
            "y" -> return KeyEvent.KEYCODE_Y
            "z" -> return KeyEvent.KEYCODE_Z
            "," -> return KeyEvent.KEYCODE_COMMA
            "." -> return KeyEvent.KEYCODE_PERIOD
            "-" -> return KeyEvent.KEYCODE_MINUS
        }
        return KeyEvent.KEYCODE_SPACE
    }
}
