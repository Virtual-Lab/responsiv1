// To receive OSC messages from rhizome
(
thisProcess.openUDPPort(9002);

// thisProcess.addOSCRecvFunc({ |args|
// 	("RECEIVED : ".ccatList(args)).postln;
// });
);

b = NetAddr.new("localhost", 9000);

// Subscribing to receive all messages
b.sendMsg("/sys/subscribe", 9002, "/");

// Now sending stuff
b.sendMsg("/note", 200,0.5,2);
b.sendMsg("/what", 200,0.5,2);
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, recvPort].postln }, '/note');
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, recvPort].postln }, '/example');

o = OSCFunc({ arg msg, time, addr, recvPort; [msg, recvPort].postln }, '/what');
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, recvPort].postln }, '/xy');