module WsdlMapperTesting
  class TmpPath
    def initialize
      @path = File.join ::TEST_TMP_PATH, SecureRandom.hex(5)
      FileUtils.mkdir_p @path
    end

    def join *args
      File.join @path, *args
    end

    def to_s
      @path
    end

    def unlink
      FileUtils.rm_rf @path
    end
  end
end
