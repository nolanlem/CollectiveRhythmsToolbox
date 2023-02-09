// which server?
/*Server.default = Server.local;
Server.default = Server.internal;*/

// boot the server!!!!
s.boot;

// RUN THIS CODE BLOCK (cmd+enter)
(
// example woodblock sample
var samplePath = thisProcess.nowExecutingPath.dirname +/+ "samples/woodblock_mono.wav";

SynthDef(\playsamp, {| out = 0, bufnum = 0, rate = 1.0, vol= 0.2 |
	Out.ar(out,
		FreeVerb.ar(
			[(vol)*PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, doneAction: Done.freeSelf),(vol)*PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, doneAction: Done.freeSelf)]));
}).add;

// read soundfile into buffer ~b
~b = Buffer.read(s, samplePath );

//Synth(\playsamp, [\rate, 1, \bufnum, ~b]);


~samplerates = Array.fill(100, {arg i; 1 + 0.5.linrand;});

n = NetAddr("127.0.0.1", 57120);

~freq_array = [0.9, 1.0, 1.1, 1.2, 1.3];
OSCdef(\receiver, {|msg|
    ~numoscs = msg.size;
	~numoscs.do({ arg i;
		//msg[i].postln;
		//var sc;
		//sc = 1/~numoscs;
		if(msg[i] == 1, {
		  Synth(\playsamp,[\rate, ~samplerates[i], \out, 0, \bufnum, ~b]);
		});
	});
	//"received trigger!".postln;
},"/trig");
)


