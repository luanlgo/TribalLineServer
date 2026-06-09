module.exports = {
  apps: [{
    name: "triballine",
    script: "./start_server.sh",
    interpreter: "bash",
    env: {
      TRIBALLINE_REDIS_URL: "redis://default:OBeCGdKvijSsTCrGPiQCOFEssJxXnUts@zephyr.proxy.rlwy.net:40233",
      GODOT_SILENCE_ROOT_WARNING: "1"
    }
  }]
}
