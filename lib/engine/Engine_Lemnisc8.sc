// Lemnisc8_Engine
// Undecided on whether this is needed

// Inherit methods from CroneEngine
Engine_Lemnisc8 : CroneEngine {
  var <synth, params;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    SynthDef(\Lemnisc8, {
      // engine is probably just a noise drone for adding tape hiss
      // and machine hum, which i'd forgotten was a thing
      // maybe enable the chunky servo click on program change (optional)
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