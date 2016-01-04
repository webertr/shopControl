Notes on serial controllers for therapy control

Jon Jacky, Oct 2012


Connections

For directions on connecting and testing the serial controllers 
through the Moxa 5610 serial device server box, see 

  therapyControl/trunk/notes/serial-ports.xt


Controllers

The three Scanditronix (scx) serial controllers are 

 TMC Treament Motion Controller
 LCC Leaf Collimator Controller
 DMC Dose Monitor Controller


Serial ports

The controllers use these settings:
 
 baud rate 1200 (except LCC uses 9600)
 7 bits per character
 even parity
 one stop bit 
  
On the Moxa box side, these are configured via telnet (see serial-ports.txt)


Protocols

The protocols for communicating with the three controllers are
described in detail in the CNTS Reference Manual, TR 99-10-01, chapter
3.  Here is a brief summary.

Usually the control program (that is, EPICS) sends a command to a
controller (an EPICS stream protocol "out" message) and the controller
responds (an EPICS stream protocol "in" message).  

Sometimes a controller sends an unsolicited message. Each
controller sends a message when it is reset at power up and when its
hardware reset button is pressed.  In addition, the DMC can send
unsolicited messages to indicate it has detected various fault
conditions.

Every command to a controller is terminated by a carriage return
*but no line feed*.

Every message from a controller is terminated by a line feed and a
carriage return *in that order*.  

Controllers respond to every command with the *acknowledgement
sequence*, a space character followed by a line feed and carriage
return.

Controllers indicate they have finished performing a command by
sending the *completion sequence*, a dollar sign (and then
the line feed and carriage return).

When a controller sends data it terminates each string of data values
with a pound sign, then a line feed and carriage return.  This is
called the *continuation sequence* because it is always followed
by another line of message text, with more data or the completion
sequence.


Timeouts

The control program will usually wait for the completion message for
up to 4 seconds.  After that, the control program indicates a timeout
error.  For a few operations, processing the command takes much
longer, and in those special cases a much longer timeout is used.
For example, leaf collimator setup has an 80 sec timeout.


Controller error messages

Controllers respond to commands with error messages.  The DMC can also
issue unsolicited error messages.

The format of an error message is  ERROR <n>; <message>
(m is the error number), then a line feed and carriage return.  When
a command evokes an error message, first the controller responds with
the acknowledgement sequence, then the error message itself, and finally the
completion sequence.


Reset

The control program sends a reset command
each time the operator selects a field (and each time the operator
presses the Refresh key (except when a run is in progress) - ?)

The reset command is a single ASCII escape character (1B hex)
followed by a carriage return.

The controller responds to the reset command with a text string or
banner that identifies the controller, then line feed and
carriage return, then the completion sequence (but no separate
acknowledgement sequence, in effect the banner string takes the place
of the space character in the usual acknowledgment sequence).


Polling

Much of the time the control program *polls* the controllers
repeatedly.  To initiate each polling cycle, the control computer
sends a command to a controller, requesting some data.  After a brief
delay, the controller responds with the acknowledgement sequence.
Then, after an appreciable delay, the controller responds with the
data, terminated by the completion sequence.  The delay accounts for
most of the polling interval, so the polling rate is limited by the
controller and cannot be increased by speeding up the program.
Polling is not strictly periodic (it is not synchronized to a regular
clock tick).  However, the polling interval is usually quite regular.
The typical interval (and corresponding frequency) for each controller
is:

 Controller   Interval  Frequency 
               (sec)    (per minute)
 TMC           1.02     59
 LCC           1.50     40
 DMC           2.40     25


Treatment Motion Controller (TMC) 

Almost always, the control program merely polls the TMC periodically
the read the actual values of the parameters in the Gantry/Couch
subsystem.

The typical polling sequence is:

1. The control computer sends the OUT ALL command to poll the TMC.
The TMC responds with the acknowledgement sequence.

2. About one second later, the TMC responds with the actual
values of all the parameters in the Gantry/Couch and
Filter/Wedge subsystems, followed by the continuation sequence:

2. The TMC sends the completion sequence. This completes one polling
cycle.

The polling rate is 59 samples/minute (1.02 second sampling interval),
determined by the TMC response time.

Here are typical messages seen in a polling cycle:

OUT ALL
1 269.9 108.0 048.6 075.6 180.0 180.3 3701 00 0090 000.0 000.0 #
$

The ordering and encoding of the setting values is:

 Flattening filter selection:  0 none, 1 large, 2 small, 9 in transition
 Collimator rotation: deg
 Couch height: cm
 Couch lateral position: cm
 Couch longitudinal position: cm
 Couch turntable rotation: deg
 Couch top rotation: deg
 Gantry rotation: 1/20 deg
 Wedge selection: 00 none, 30 deg, 45 deg, 60 deg, 99 in transition
 Wedge rotation: 0000 deg, 0090 deg, 0180 deg, 0270 deg, 0099 in transition

Encoded gantry rotation e is a 4 digit integer, each unit 1/20
degree. Top (zero) is 3701 (not 3700), decoded values range from 0.0
to 359.9. Decoded gantry rotation d is

 d = (e - 3701)/20.0

gantry = d if d >= 0.0 and 360.0 + d otherwise.

Each time the operator selects a new field (or presses the refresh key
-?) (except while a run is in progress), the program resets the TMC
(here the escape character is indicated by ^[ as it appears in
telnet):

^[
"TMC Vers 1.1 841206 . PHa."
$

If the TMC does not respond to a command (including a poll) as
expected, responds with an error message, or sends an unsolicited
message, the control program sets the TMC Error interlock and stops
polling the TMC.

The only way to recover from this condition is to select a field again
(or press the Refresh key - ?).  If the TMC responds correctly the
program clears the TMC Error interlock and resumes polling again.

(At one time the TMC set up the flattening filter and wedges.  It
still supports commands for that, but those functions have been
delegated to Modicon 2 and now those commands are never used.)

