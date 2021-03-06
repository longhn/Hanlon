module ProjectHanlon
  module ImageService
    # Image construct for generic Operating System install ISOs
    class VMwareHypervisor < ProjectHanlon::ImageService::Base

      attr_accessor :esxi_version
      attr_accessor :boot_cfg

      def initialize(hash)
        super(hash)
        @description = "VMware Hypervisor Install"
        @path_prefix = "esxi"
        @hidden = false
        from_hash(hash) unless hash == nil
      end

      def add(src_image_path, lcl_image_path, extra)
        begin
          resp = super(src_image_path, lcl_image_path, extra)
          if resp[0]
            unless verify(lcl_image_path)
              logger.error "Missing metadata"
              return [false, "Missing metadata"]
            end
            return resp
          else
            resp
          end
        rescue => e
          logger.error e.message
          return [false, e.message]
        end
      end

      def verify(lcl_image_path)
        super(lcl_image_path)
        unless super(lcl_image_path)
          logger.error "File structure is invalid"
          return false
        end

        if File.exist?("#{image_path}/vmware-esx-base-osl.txt") && File.exist?("#{image_path}/boot.cfg")
          begin
            @esxi_version = File.read("#{image_path}/vmware-esx-base-osl.txt").split("\n")[2].gsub("\r","")

            @boot_cfg =  File.read("#{image_path}/boot.cfg")

            if @esxi_version && @boot_cfg
              return true
            end

            false
          rescue => e
            logger.debug e
            false
          end
        else
          logger.error "Does not look like an ESXi ISO"
          false
        end
      end

      def print_image_info(lcl_image_path)
        super(lcl_image_path)
        print "\tVersion: "
        print "#{@esxi_version}  \n".green
      end

      def print_item_header
        super.push "Version"
      end

      def print_item
        super.push @esxi_version
      end

    end
  end
end
