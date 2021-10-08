void AL_ProjectProjectile (entity projectile, float velocity) {
      // Project projectiles player ping forward in time based on ping up to a maximum of 150ms      
      // Effective projection time is 75ms, because we assume RTT is evenly distributed in both
      // directions - and we want the server to spawn the entity in the position it would have
      // have been if it had received the message (player_ping / 2) ago. 
      local float player_ping_s = infokeyf(self, INFOKEY_P_PING) / 1000;
      // Remove 13ms / 1 frame to keep behaviour consistent on low ping
      player_ping_s = player_ping_s - (0.01298701298); // 1/77
      if (player_ping_s > 0.15) {
          player_ping_s = 0.15;
      } else if (player_ping_s < 0.0013) {
          player_ping_s = 0;
      }
              
      local float rocket_offset = (player_ping_s  / 2) * velocity;
      local vector projected_origin = newmis.origin + v_forward * (rocket_offset);
      
      // Rewind projectile is preferable but unavailable. This would rewind and replay the projectile from origin
      // to the projected origin. Since it isn't available, we will use a traceline, without MOVE_LAGGED
      // because by tracing between old origin and projected origin we effectively have a single (last) frame 
      // rewind at the projected origin. The effect is high ping players are disadvantaged in close combat.
      // This is preferable to unhappy low ping players.
      traceline(newmis.origin, projected_origin, 0, self);

      if (trace_fraction < 1) {
          projected_origin = trace_endpos;
      }

      setorigin(newmis, projected_origin);
}