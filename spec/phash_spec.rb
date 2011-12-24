require File.dirname(__FILE__) + '/spec_helper.rb'

describe :Phash do
  data_dir = FSPath(__FILE__).dirname / 'data'

  describe :Audio do
    let(:paths){ data_dir.glob('*.mp3') }
    let(:audios){ Phash::Audio.for_paths(paths) }

    it "should return valid distances" do
      audios.combination(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should > 0.9
        else
          distance.should < 0.5
        end
      end
    end

    it "should return same distance if swapping audios" do
      audios.combination(2) do |a, b|
        a.distance(b).should == b.distance(a)
      end
    end
  end

  describe :Text do
    let(:paths){ data_dir.glob('*.h') }
    let(:texts){ Phash::Text.for_paths(paths) }

    it "should return valid distances" do
      texts.combination(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should > 1
        else
          distance.should < 0.5
        end
      end
    end

    it "should return same distance if swapping texts" do
      texts.combination(2) do |a, b|
        a.distance(b).should == b.distance(a)
      end
    end
  end

  describe :Video do
    let(:paths){ data_dir.glob('*.mp4') }
    let(:videos){ Phash::Video.for_paths(paths) }

    it "should return valid distances" do
      videos.combination(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should > 0.9
        else
          distance.should < 0.5
        end
      end
    end

    it "should return same distance if swapping videos" do
      videos.combination(2) do |a, b|
        a.distance(b).should == b.distance(a)
      end
    end
  end
end
