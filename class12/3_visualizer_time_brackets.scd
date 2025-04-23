// Time Bracket Generator with Improved Distribution

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

// ===== VISUALIZATION =====

// Define colors for each part
~partColors = [
    Color.new255(220, 50, 50),    // Red
    Color.new255(50, 180, 50),    // Green
    Color.new255(80, 80, 220),    // Blue
    Color.new255(220, 180, 0),    // Yellow
    Color.new255(180, 50, 180),   // Purple
    Color.new255(50, 180, 180),   // Cyan
    Color.new255(220, 120, 50),   // Orange
    Color.new255(150, 150, 150)   // Gray
];

// Create the timeline window
~timelineWidth = 900;
~timelineHeight = ~numParts * 40 + 80;
~window = Window("Time Bracket Timeline", Rect(100, 100, ~timelineWidth, ~timelineHeight));

// Calculate some layout parameters
~margin = 40;
~trackHeight = 30;
~trackSpacing = 40;
~timelineLength = ~timelineWidth - (~margin * 2);
~pixelsPerSecond = ~timelineLength / (~totalDuration * 60);

// Running time for the stopwatch
~currentTime = 0;

// For X durations, assume this length for visualization
~xDurationLength = 10; // seconds

// Time to X-position conversion function
~timeToX = {|time|
    ~margin + (time * ~pixelsPerSecond);
};

// Create a UserView for custom drawing
~userView = UserView(~window, Rect(0, 0, ~timelineWidth, ~timelineHeight));

// Draw function that avoids variable declarations and the 'darker' method
~userView.drawFunc = {
    // Draw background
    Pen.fillColor = Color.white;
    Pen.fillRect(Rect(0, 0, ~timelineWidth, ~timelineHeight));

    // Draw timeline grid
    Pen.fillColor = Color.black;

    // Draw third-markers - lighter background for each third
    Pen.fillColor = Color.gray(0.95);
    Pen.fillRect(Rect(~timeToX.(~totalDuration * 60 * 2/3), ~margin - 15,
                     ~timeToX.(~totalDuration * 60) - ~timeToX.(~totalDuration * 60 * 2/3),
                     ~timelineHeight - ~margin - 5));

    Pen.fillColor = Color.gray(0.97);
    Pen.fillRect(Rect(~timeToX.(~totalDuration * 60 * 1/3), ~margin - 15,
                     ~timeToX.(~totalDuration * 60 * 2/3) - ~timeToX.(~totalDuration * 60 * 1/3),
                     ~timelineHeight - ~margin - 5));

    // Draw minute markers - using global temp variables
    ~i = 0;
    while { ~i <= ~totalDuration } {
        ~x = ~timeToX.(~i * 60);

        // Draw vertical line
        Pen.strokeColor = Color.gray(0.7);
        Pen.width = 1;
        Pen.line(Point(~x, ~margin), Point(~x, ~timelineHeight - 20));
        Pen.stroke;

        // Draw minute label
        Pen.fillColor = Color.black;
        Pen.stringAtPoint(~i.asString, Point(~x - 5, ~timelineHeight - 15));

        ~i = ~i + 1;
    };

    // Draw horizontal lines for parts
    ~i = 0;
    while { ~i < ~numParts } {
        ~y = ~margin + (~i * ~trackSpacing);

        // Draw part label
        Pen.stringAtPoint("Part " ++ (~i+1), Point(5, ~y + (~trackHeight/2) - 5));

        // Draw horizontal line
        Pen.strokeColor = Color.gray(0.8);
        Pen.width = 1;
        Pen.line(Point(~margin, ~y), Point(~timelineWidth - ~margin, ~y));
        Pen.stroke;

        Pen.line(Point(~margin, ~y + ~trackHeight), Point(~timelineWidth - ~margin, ~y + ~trackHeight));
        Pen.stroke;

        ~i = ~i + 1;
    };

    // Draw entries for each part
    ~i = 0;
    while { ~i < ~parts.size } {
        ~y = ~margin + (~i * ~trackSpacing);
        ~part = ~parts[~i];

        ~j = 0;
        while { ~j < ~part.size } {
            ~entry = ~part[~j];
            ~startTime = ~entry[0];
            ~startX = ~timeToX.(~startTime);

            // Handle X endings vs fixed endings
            if(~entry[1] == "X") {
                ~tempEndTime = ~startTime + ~xDurationLength;
                ~endX = ~timeToX.(~tempEndTime);

                // X durations shown with pattern - use lighter color
                Pen.fillColor = ~partColors[~i].copy.alpha_(0.5);
                // Use black for border
                ~borderColor = Color.black.alpha_(0.6);
            } {
                ~endX = ~timeToX.(~entry[1]);

                // Regular durations shown with solid color
                Pen.fillColor = ~partColors[~i].copy.alpha_(0.8);
                // Use black for border
                ~borderColor = Color.black.alpha_(0.7);
            };

            ~blockWidth = ~endX - ~startX;

            // Draw the entry rectangle
            Pen.fillRect(Rect(~startX, ~y, ~blockWidth, ~trackHeight));

            // Draw border
            Pen.strokeColor = ~borderColor;
            Pen.width = 1;
            Pen.strokeRect(Rect(~startX, ~y, ~blockWidth, ~trackHeight));

            // Add pattern for X durations
            if(~entry[1] == "X") {
                ~patternStep = 5;
                ~lineCount = (~blockWidth / ~patternStep).floor;

                Pen.strokeColor = Color.black.alpha_(0.4);
                Pen.width = 1;

                ~k = 0;
                while { ~k < ~lineCount } {
                    ~lineX = ~startX + (~k * ~patternStep);
                    Pen.line(Point(~lineX, ~y), Point(~lineX + ~patternStep, ~y + ~trackHeight));
                    Pen.stroke;

                    ~k = ~k + 1;
                };
            };

            ~j = ~j + 1;
        };

        ~i = ~i + 1;
    };

    // Draw current time marker
    ~timeX = ~timeToX.(~currentTime);

    // Red vertical line for current time
    Pen.strokeColor = Color.red;
    Pen.width = 2;
    Pen.line(Point(~timeX, ~margin - 15), Point(~timeX, ~timelineHeight - 20));
    Pen.stroke;

    // Current time indicator
    Pen.fillColor = Color.white;
    Pen.fillRect(Rect(~timeX - 25, ~margin - 25, 50, 20));
    Pen.strokeRect(Rect(~timeX - 25, ~margin - 25, 50, 20));

    Pen.fillColor = Color.red;
    Pen.stringCenteredIn(~formatTime.(~currentTime),
        Rect(~timeX - 25, ~margin - 25, 50, 20));
};

// Create timer for advancing the timeline marker
~timerClock = TempoClock(1); // 1 beat per second
~timerTask = Task({
    loop {
        // Update time
        ~currentTime = ~currentTime + 0.1;

        // Refresh the view
        {~userView.refresh}.defer;

        // 100ms refresh rate for smooth animation
        0.1.wait;

        // Reset if we reach the end of the timeline
        if(~currentTime >= (~totalDuration * 60)) {
            ~currentTime = 0;
        };
    };
});

// Control buttons
~buttonWidth = 80;
~buttonHeight = 25;
~buttonSpacing = 10;
~buttonY = ~timelineHeight - 35;

// Add Start button
~startButton = Button(~window, Rect(~margin, ~buttonY, ~buttonWidth, ~buttonHeight))
    .states_([["Start", Color.black, Color.new255(200, 255, 200)]])
    .action_({
        ~timerTask.play(~timerClock);
    });

// Add Pause button
~pauseButton = Button(~window, Rect(~margin + ~buttonWidth + ~buttonSpacing, ~buttonY, ~buttonWidth, ~buttonHeight))
    .states_([["Pause", Color.black, Color.new255(255, 255, 200)]])
    .action_({
        ~timerTask.pause;
    });

// Add Reset button
~resetButton = Button(~window, Rect(~margin + (~buttonWidth + ~buttonSpacing) * 2, ~buttonY, ~buttonWidth, ~buttonHeight))
    .states_([["Reset", Color.black, Color.new255(255, 200, 200)]])
    .action_({
        ~currentTime = 0;
        ~userView.refresh;
    });

// Add regenerate button
~regenerateButton = Button(~window, Rect(~margin + (~buttonWidth + ~buttonSpacing) * 3, ~buttonY, ~buttonWidth, ~buttonHeight))
    .states_([["Regenerate", Color.black, Color.new255(200, 200, 255)]])
    .action_({
        // Close current window and rerun this entire code
        ~window.close;
        "Regenerating time brackets...".postln;
        this.interpret(thisProcess.interpreter.cmdLine);
    });

// Update control
~scrubSlider = Slider(~window, Rect(~margin + (~buttonWidth + ~buttonSpacing) * 4 + 10, ~buttonY, ~timelineWidth - ~margin - (~buttonWidth + ~buttonSpacing) * 4 - 50, ~buttonHeight))
    .action_({|slider|
        ~currentTime = slider.value * (~totalDuration * 60);
        ~userView.refresh;
    });

// Show the window
~window.front;

// Start the timer automatically
~timerTask.play(~timerClock);

// Function to stop everything when the window is closed
~window.onClose = {
    ~timerTask.stop;
    ~timerClock.stop;
};

// Print a summary of the generated score
"\n=== SCORE SUMMARY ===".postln;
"Total duration: % minutes".format(~totalDuration).postln;
~earlyTotal = 0; ~midTotal = 0; ~lateTotal = 0;
~parts.do {|part, i|
    ~earlyCount = 0; ~midCount = 0; ~lateTotal = 0;
    part.do {|entry|
        if(entry[0] < (~totalDuration * 60 / 3)) { ~earlyCount = ~earlyCount + 1; ~earlyTotal = ~earlyTotal + 1; }
        { if(entry[0] < (~totalDuration * 60 * 2/3)) { ~midCount = ~midCount + 1; ~midTotal = ~midTotal + 1; }
        { ~lateTotal = ~lateTotal + 1; }};
    };

    "Part %: % entries (early: %, mid: %, late: %)".format(
        i+1, part.size, ~earlyCount, ~midCount, (part.size - ~earlyCount - ~midCount)
    ).postln;

    if(part.size > 0) {
        "  First entry: % --- %".format(~formatTime.(part.first[0]), ~formatTime.(part.first[1])).postln;
        "  Last entry: % --- %".format(~formatTime.(part.last[0]), ~formatTime.(part.last[1])).postln;
    };
};
"Total Distribution: % early, % mid, % late".format(~earlyTotal, ~midTotal, ~lateTotal).postln;
"=== END OF SUMMARY ===\n".postln;
)