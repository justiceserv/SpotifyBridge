const osascript = require('node-osascript');

// Example to control Spotify
/*
osascript.execute('tell application "Spotify" to play', function(err, result, raw) {
    if (err) return console.error(err);
    console.log(result);
});
*/ 

const checkPlayerStateScript = `
tell application "Spotify"
    return player state
end tell
`;

osascript.execute(checkPlayerStateScript, function(err, result, raw) {
    if (err) return console.error(err);
    console.log(`Player State: ${result}`);
});

const getTrackPositionScript = `
tell application "Spotify"
    set trackPosition to player position
    set trackDuration to duration of current track
    return trackPosition & " seconds out of " & (trackDuration / 1000) & " seconds"
end tell
`;

osascript.execute(getTrackPositionScript, function(err, result, raw) {
    if (err) return console.error(err);
    console.log(`Track Position: ${result}`);
});
