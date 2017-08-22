# VoiceMemo-Liulishuo
A simple and fun voice memo project for interview of liulishuo

requirements:
1. On first viewcontroller, implement recording and playback feature, hold the record button to record, release to end, click play button to play the audio just recorded.

2. Use right top corner button to enter the second page, display recordings in cells, which contains a play button and filename(up to you), to play, click on the play button on cell to play, click on playing cell to stop, playing cell should be tagged. when the list is long, cell should maintain its states when scrolling.

3. Use Core Data

it mimicked the apple visualizeable voice mail, using speech dication to summarize the content of the recordings

TODO:
Make a UISearchController to search through the list (should be easy)
Make a audio playback control on UIWindow level, should make it work on lock screen too
Make a more elegant permission request guidence interface


![alt text](https://github.com/felyfely/VoiceMemo-Liulishuo/blob/master/VoiceMemo/recording.PNG "recording")

![alt text](https://github.com/felyfely/VoiceMemo-Liulishuo/blob/master/VoiceMemo/history.PNG "history")
