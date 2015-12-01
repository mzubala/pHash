require 'phash'

module Phash
  # compute dct robust image hash
  #
  # param file string variable for name of file
  # param hash of type ulong64 (must be 64-bit variable)
  # return int value - -1 for failure, 1 for success
  #
  # int ph_dct_imagehash(const char* file, ulong64 &hash);
  #
  attach_function :ph_dct_imagehash, [:string, :pointer], :int, :blocking => true

  # no info in pHash.h
  #
  # int ph_hamming_distance(const ulong64 hash1,const ulong64 hash2);
  #
  attach_function :ph_hamming_distance, [:uint64, :uint64], :int, :blocking => true

  class Digest < FFI::Struct
    layout id: :string,
      coeffs: :pointer,
      size: :int

    def coeffs
      self[:coeffs].read_array_of_type(:uint8, :read_uint8, self[:size])
    end

    def self.from_coeffs(coeffs)
      digest = new
      digest[:coeffs] = FFI::MemoryPointer.new(:uint8, coeffs.size)
      digest[:coeffs].put_array_of_uint8(0, coeffs)
      digest[:size] = coeffs.size
      digest
    end

    def free
      self[:coeffs].free if self[:coeffs]
      self[:id].free if self[:id]
    end

  end

  attach_function :ph_image_digest, [:string, :double, :double, Digest.by_ref, :int], :int, blocking: true

  attach_function :ph_crosscorr, [Digest.by_ref, Digest.by_ref, :pointer], :int, blocking: true

  class << self
    # Get image file hash using <tt>ph_dct_imagehash</tt>
    def image_hash(path)
      hash_p = FFI::MemoryPointer.new :ulong_long
      if -1 != ph_dct_imagehash(path.to_s, hash_p)
        hash = hash_p.get_uint64(0)
        hash_p.free

        ImageHash.new(hash)
      end
    end

    def image_radial_hash(path)
      digest = Digest.new
      if -1 != ph_image_digest(path.to_s, 1.0, 1.0, digest, 180)
        arr = digest.coeffs
        digest.free
        arr
      end
    end

    def image_crosscor(hash_a, hash_b)
      pcc = FFI::MemoryPointer.new :double
      d1 = Digest.from_coeffs(hash_a)
      d2 = Digest.from_coeffs(hash_b)
      if -1 != ph_crosscorr(d1, d2, pcc)
        cor = pcc.get_float64(0)
        pcc.free
        d1.free
        d2.free
        cor
      end
    end

    # Get distance between two image hashes using <tt>ph_hamming_distance</tt>
    def image_hamming_distance(hash_a, hash_b)
      hash_a.is_a?(ImageHash) or raise ArgumentError.new('hash_a is not an ImageHash')
      hash_b.is_a?(ImageHash) or raise ArgumentError.new('hash_b is not an ImageHash')

      ph_hamming_distance(hash_a.data, hash_b.data)
    end

    # Get similarity from hamming_distance
    def image_similarity(hash_a, hash_b)
      1 - image_hamming_distance(hash_a, hash_b) / 64.0
    end
  end

  # Class to store image hash and compare to other
  class ImageHash < HashData
  end

  # Class to store image file hash and compare to other
  class Image < FileHash
  end
end
