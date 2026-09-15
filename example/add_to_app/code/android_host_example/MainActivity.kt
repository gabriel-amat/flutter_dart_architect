package com.example.enterprise.host

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineGroup

/// Native Android Activity demonstrating FlutterEngineGroup pooling.
/// Eliminates the ~25MB standalone engine memory overhead and avoids UI jank.
class MainActivity : AppCompatActivity() {

    companion object {
        // Shared engine group across the Android application lifecycle
        lateinit var engineGroup: FlutterEngineGroup
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        engineGroup = FlutterEngineGroup(this)
    }

    /// Spawns a lightweight FlutterActivity from the cached engine group
    fun launchCheckout() {
        val intent = FlutterActivity
            .withNewEngine()
            .engineGroupId("enterprise_engine_group")
            .dartEntrypointFunctionName("checkoutEntryPoint")
            .build(this)

        startActivity(intent)
    }
}
