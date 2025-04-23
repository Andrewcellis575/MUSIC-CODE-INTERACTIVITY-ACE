(
// ===== CONFIGURATION PARAMETERS =====

// Basic configuration
~totalDuration = 8;     // Total duration in minutes
~numParts = 4;          // Number of parts
~entriesPerPart = 10;   // Target entries per part (may generate fewer if time runs out)

// Musical parameters (0.0-1.0)
~density = 0.1;         // Overall density
~xProbability = 0.3;    // X ending probability
~bunchiness = 0.5;      // How bunched entries are
~staggering = 0.5;      // Part offset

/* Presets:
Sparse, contemplative:
~density = 0.2; ~xProbability = 0.4; ~bunchiness = 0.3; ~staggering = 0.8;
Dense, active:
~density = 0.8; ~xProbability = 0.3; ~bunchiness = 0.7; ~staggering = 0.4;
Structured, predictable:
~density = 0.5; ~xProbability = 0.2; ~bunchiness = 0.3; ~staggering = 0.2;
Freedom-oriented:
~density = 0.5; ~xProbability = 0.7; ~bunchiness = 0.6; ~staggering = 0.5;
*/

// Distribution settings
~distributionBalance = 0.5;  // 0.0 = front-loaded, 1.0 = back-loaded, 0.5 = balanced
~fullRangeSpread = true;     // Ensures some entries in each third of the time span

// ===== DURATION CALCULATION =====

// Gap settings - adjust these to control maximum density
~gapOffsetMin = 2;      // Minimum gap between entries (seconds)
~gapOffsetMax = 30;     // Maximum gap between entries (seconds) - increased for better spread

// Calculate timing values based on density
~minDuration = 3 * (1 - (~density * 0.3));
~maxDuration = 25 * (1 - (~density * 0.5));
~minGap = ~gapOffsetMin * (1 + ((1 - ~density) * 2));
~maxGap = ~gapOffsetMax * (1 + ((1 - ~density) * 3));

// ===== HELPER FUNCTIONS =====

// Format time as MM:SS
~formatTime = {|seconds|
    if(seconds.isKindOf(String), {
        // Handle the case where seconds is "X"
        "X";
    }, {
        var minutes = (seconds / 60).floor;
        var secs = seconds % 60;
        minutes.asInteger.asString.padLeft(2, "0") ++ ":" ++ secs.round(1).asInteger.asString.padLeft(2, "0");
    });
};

// Adaptive gap calculation - increases likelihood of larger gaps as time progresses
~calculateGap = {|currentTime, normalGap|
    var progress = currentTime / (~totalDuration * 60);
    var scaleFactor;

    // Scale factor increases as we progress through the piece
    if (~distributionBalance > 0.5) {
        // Favor entries in latter parts (gaps smaller as we progress)
        scaleFactor = 1 - (progress * (~distributionBalance - 0.5) * 1.5);
    } {
        // Favor entries in early parts (gaps larger as we progress)
        scaleFactor = 1 + (progress * (0.5 - ~distributionBalance) * 1.5);
    };

    // Occasionally add extra large gaps to ensure better spread
    if (0.15.coin) {
        normalGap * scaleFactor * rrand(1.5, 3.0);
    } {
        normalGap * scaleFactor;
    };
};

// ===== GENERATE TIME BRACKETS =====

// Create empty parts array
~parts = Array.new;

// Generate parts
~numParts.do {|i|
    ~entries = Array.new;
    ~currentTime = ~staggering * rrand(1, 20) * (i+1);
    ~currentTime = ~currentTime.min(60);

    "Generating Part %".format(i+1).postln;

    // Generate entries for this part
    ~entryCount = 0;
    ~xStreak = 0;

    // Track coverage of the total duration
    ~earlyCount = 0; // First third
    ~midCount = 0;   // Middle third
    ~lateCount = 0;  // Last third

    // Ensure at least some entries in each third of the piece
    ~ensureFullRangeCoverage = ~fullRangeSpread;

    // Keep generating until we reach either the entry limit or time limit
    while {(~entryCount < ~entriesPerPart) && (~currentTime < (~totalDuration * 60))} {
        // Entry start time
        ~startTime = ~currentTime;

        // Determine if X ending
        ~localXProb = ~xProbability;
        if((~xStreak > 0) && (~bunchiness > 0.3)) {
            ~localXProb = ~xProbability * (1 + ~bunchiness);
        };

        if(~localXProb.coin) {
            ~endTime = "X";
            ~duration = rrand(3, 8);
            ~xStreak = ~xStreak + 1;
        } {
            ~duration = rrand(~minDuration, ~maxDuration);
            ~endTime = ~startTime + ~duration;
            ~xStreak = 0;
        };

        // Add this entry
        ~entries = ~entries.add([~startTime, ~endTime]);

        // Update counts for distribution tracking
        if (~startTime < (~totalDuration * 60 / 3)) {
            ~earlyCount = ~earlyCount + 1;
        } {
            if (~startTime < (~totalDuration * 60 * 2/3)) {
                ~midCount = ~midCount + 1;
            } {
                ~lateCount = ~lateCount + 1;
            };
        };

        // Debug output to track progress
        "  Entry %: % --- %".format(
            ~entryCount + 1,
            ~formatTime.(~startTime),
            ~formatTime.(~endTime)
        ).postln;

        // Calculate normal gap based on bunchiness
        if(~bunchiness.coin) {
            ~normalGap = rrand(~minGap, ~minGap * 2);
        } {
            ~normalGap = rrand(~minGap, ~maxGap);
        };

        // Apply adaptive gap calculation
        ~gap = ~calculateGap.(~startTime, ~normalGap);

        // If we need better coverage of later parts and we're in early sections
        if(~ensureFullRangeCoverage && (~entryCount > 5) && (~lateCount < 2) && (~startTime < (~totalDuration * 60 * 0.5))) {
            // Make a big jump to ensure late coverage
            if(0.4.coin) {
                ~jumpTarget = rrand(~totalDuration * 60 * 0.6, ~totalDuration * 60 * 0.9);
                "  Making a jump to % to ensure later coverage".format(~formatTime.(~jumpTarget)).postln;
                ~currentTime = ~jumpTarget;
                ~ensureFullRangeCoverage = false; // Only do this once
            };
        } {
            // Normal time advancement
            ~currentTime = ~startTime + ~duration + ~gap;
        };

        // Debug output
        "  Next entry will start at: %".format(~formatTime.(~currentTime)).postln;

        ~entryCount = ~entryCount + 1;
    };

    // Add this part to all parts
    ~parts = ~parts.add(~entries);

    // Display last entry information - handle "X" case properly
    if (~entries.size > 0) { // Make sure we have at least one entry
        ~lastEntryInfo = if(~entries.last[1] == "X",
            "X (from % + indeterminate)".format(~formatTime.(~entries.last[0])),
            ~formatTime.(~entries.last[1]));

        "  Generated % entries for Part %, last entry ends at: %".format(
            ~entries.size,
            i+1,
            ~lastEntryInfo
        ).postln;

        // Display distribution information
        "  Distribution: Early=% (first third), Mid=% (middle third), Late=% (last third)".format(
            ~earlyCount, ~midCount, ~lateCount
        ).postln;
    } {
        "  No entries were generated for Part %".format(i+1).postln;
    };
};

// ===== PRINT SCORE =====

// Print parameters
"\n=== SCORE PARAMETERS ===".postln;
"Duration: % minutes, % parts".format(~totalDuration, ~numParts).postln;
"Density: %, X Probability: %, Bunchiness: %, Staggering: %".format(
    ~density, ~xProbability, ~bunchiness, ~staggering
).postln;
"Distribution Balance: %, Full Range Coverage: %".format(
    ~distributionBalance, ~fullRangeSpread
).postln;

// Print the time brackets
"\n=== TIME BRACKETS ===\n".postln;

~parts.do {|part, i|
    "\nPART %\n".format(i+1).postln;

    part.do {|entry|
        ~start = ~formatTime.(entry[0]);
        ~end = ~formatTime.(entry[1]);

        "> % --- %".format(~start, ~end).postln;
    };
};

"=== END OF SCORE ===\n".postln;
)