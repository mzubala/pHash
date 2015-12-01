require File.dirname(__FILE__) + '/spec_helper.rb'

describe :Phash do
  include SpecHelpers

  shared_examples :similarity do
    it "should return valid similarities" do
      collection.combination(2) do |a, b|
        if main_name(a.path) == main_name(b.path)
          (a % b).should > 0.8
        else
          (a % b).should <= 0.5
        end
      end
    end

    it "should return same similarity if swapping instances" do
      collection.combination(2) do |a, b|
        (a % b).should == (b % a)
      end
    end
  end

  describe :Image do
    let(:collection) { Phash::Image.for_paths filenames('**/*.{jpg,png}') }
    include_examples :similarity

    it "should return image radial hash" do
      collection.each do |img|
        coeffs = Phash.image_radial_hash(img.path)
        expect(coeffs).to be_an(Array)
      end
    end

    it "should compare image radial hashes of same images" do
      collection.each do |img|
        coeffs = Phash.image_radial_hash(img.path)
        expect(Phash.image_crosscor(coeffs, coeffs)).to eq(1.0)
      end
    end

    it "should compare image radial hashes" do
      collection.combination(2) do |a, b|
        coeffs1 = Phash.image_radial_hash(a.path)
        coeffs2 = Phash.image_radial_hash(b.path)
        expect(Phash.image_crosscor(coeffs1, coeffs2)).to be_a(Numeric)
      end
    end

  end

  describe :Text do
    let(:collection) { Phash::Text.for_paths filenames('*.txt') }
    include_examples :similarity
  end

  # describe :Video do
  #   let(:collection){ Phash::Video.for_paths filenames('*.mp4') }
  #   include_examples :similarity
  # end
end
