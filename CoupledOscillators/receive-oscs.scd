Server.default = Server.local;
Server.default = Server.internal;

//
s.boot;

(
SynthDef(\playsamp, {| out = 0, bufnum = 0, rate = 1.0, vol= 0.2 |
	Out.ar(out,
		FreeVerb.ar(
			[(vol)*PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, doneAction: Done.freeSelf),(vol)*PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, doneAction: Done.freeSelf)]));
}).add;
~b = Buffer.read(s, "./samples/woodblock_mono.wav" );
)

Synth(\playsamp, [\rate, 1, \bufnum, ~b]);

(
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


OSCFunc.trace(true);

~numoscs = 36;
~b = Buffer.read(s, "/Users/nolanlem/Documents/kura/kura_chuck/samples/woodblock_mono.wav" ); // remember to free the buffer later.



//~synth = Array.newClear(~numoscs);
//with sample buf
(
SynthDef(\playsamp, {| out = 0, bufnum = 0, rate = 1.0, vol= 0.2 |
	Out.ar(out,
		FreeVerb.ar(
			[(vol)*PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, doneAction: Done.freeSelf),(vol)*PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, doneAction: Done.freeSelf)]));
}).add;
)

Synth(\playsamp,[\rate, ~freq_array[i], \out, 0, \bufnum, ~b]);
~freq_array = Array.fill(~numoscs, {arg i; (i+1)*0.1});

