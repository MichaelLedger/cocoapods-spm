module Pod
  module SPM
    class Resolver
      class RecursiveTargetResolver
        require "cocoapods-spm/swift/package/project_packages"

        include Config::Mixin

        def initialize(podfile, result)
          @podfile = podfile
          @result = result
        end

        def resolve
          resolve_recursive_targets
        end

        private

        def project_pkgs
          @result.project_pkgs ||= Swift::ProjectPackages.new(
            src_dir: spm_config.pkg_checkouts_dir,
            write_json_to_dir: spm_config.pkg_metadata_dir
          )
        end

        def resolve_recursive_targets
          @result.spm_dependencies_by_target.values.flatten.uniq(&:product).each do |dep|
            next if dep.pkg.try(:use_default_xcode_linking?)

            @podfile.platforms.each do |platform|
              project_pkgs.resolve_recursive_targets_of(dep.pkg.name, dep.product, platform: platform)
            end
          end
        end
      end
    end
  end
end
