package meta.state;

import meta.MusicBeat.MusicBeatState;

class VideoState extends MusicBeatState {

    public static var videoName:String;

    override public function create() {
        super.create();

        #if VIDEOS_ALLOWED
        var filepath:String = Paths.video(videoName);
        #end
    }

    public function close() 
        Main.switchState(this, new PlayState());
}