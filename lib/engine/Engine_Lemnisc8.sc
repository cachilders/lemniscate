// Lemnisc8_Engine
// Undecided on whether this is needed

// Inherit methods from CroneEngine
Engine_Asterion : CroneEngine {
  var <synth, params;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    SynthDef(\Lemnisc8, {
      
    }).add;

    context.server.sync;

    synth = Synth(\Lemnisc8, target:context.server);

    params = Dictionary.newFrom([]);
    
    params.keysDo({ arg key;
      this.addCommand(key, "f", { arg msg;
        synth.set(key, msg[1])
      });
    });
  }

  free {
    synth.free;
  }
}