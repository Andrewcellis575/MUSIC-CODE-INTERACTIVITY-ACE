// Super Simple Time Bracket Generator

(
// Configuration - bare minimum
var totalDuration = 8; // minutes
var numParts = 4;
var entriesPerPart = 15;
var minDuration = 3; // seconds
var maxDuration = 25; // seconds
var minGap = 2; // seconds
var maxGap = 40; // seconds
var xProbability = 0.3; // chance of X ending

//
//The gap in the time bracket generator represents the silence or space between consecutive entries for a performer. It's the amount of time (in seconds) between when one entry ends and the next one begins.

// Function to generate one part
var generatePart = {
    var currentTime = 0; // Start at zero
    var entries = [];
    var i = 0;

    // Use a while loop instead of do loop for more control
    while {
        (i < entriesPerPart) && (currentTime < (totalDuration * 60))
    } {
        var startTime = currentTime;
        var endTime, duration;

        // Determine if this will have an X ending
        if(xProbability.coin) {
            endTime = "X";
            duration = 5; // Default assumed duration for scheduling next
        } {
            duration = rrand(minDuration, maxDuration);
            endTime = startTime + duration;
        };

        // Add this entry
        entries = entries.add([startTime, endTime]);

        // Move time forward
        currentTime = startTime + duration + rrand(minGap, maxGap);

        // Increment counter
        i = i + 1;
    };

    entries;
};

// Generate all parts
var parts = Array.fill(numParts, { generatePart.value });

// Format time as MM:SS
var formatTime = {|seconds|
    var minutes = (seconds / 60).floor;
    var secs = seconds % 60;

    minutes.asInteger.asString.padLeft(2, "0") ++ ":" ++ secs.round(1).asInteger.asString.padLeft(2, "0");
};

// Print the results
"\n=== TIME BRACKETS ===\n".postln;

parts.do {|part, i|
    "PART %\n".format(i+1).postln;

    part.do {|entry|
        var start = formatTime.(entry[0]);
        var end = if(entry[1] == "X") { "X" } { formatTime.(entry[1]) };

        "> % --- %".format(start, end).postln;
    };

    "\n".postln;
};

"=== END OF SCORE ===".postln;
)