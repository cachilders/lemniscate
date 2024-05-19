// Lemnisc8_Engine

Engine_Lemnisc8 : CroneEngine {
  var <synth;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    var buffers, file_ext, file_names, path;
    file_ext = ".wav";
	  file_names = ["machine", "eject", "insert", "program_select", "record"];
    path = "/home/we/dust/code/lemniscate/assets/samples/";
    buffers = Dictionary.new;
    file_names.do({ arg key, i;
      buffers.put(key.asSymbol, Buffer.read(context.server, path ++ key ++ file_ext));
    });

    SynthDef(\Lemnisc8, {
      arg amp=1.0, buf=0, loop=0, t_trig=1;
	    var sample = PlayBuf.ar(1, buf, trigger: t_trig, doneAction: 2);
      Out.ar(0, Splay.ar([sample]) * amp);
    }).add;

    context.server.sync;

    this.addCommand(\play, "sf", {
      arg msg;
      Synth.new(\Lemnisc8, [buf: buffers[msg[1]], amp: msg[2]], context.server);
    });
  }

  free {
    context.server.freeAll;
  }
}