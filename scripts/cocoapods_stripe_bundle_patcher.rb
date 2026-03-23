# frozen_string_literal: true

# CocoaPods post_install script: fixes Stripe resource bundle names when using
# SpreedlyStripeAPM with CocoaPods. SpreedlyStripeAPM.xcframework was built with
# Stripe via SPM and looks for bundles named Stripe_Stripe*; CocoaPods provides
# different names. This script patches the embed script and adds a Run Script
# phase to copy/rename bundles so the XCFramework finds them at runtime.
#
# Usage in Podfile:
#   post_install do |installer|
#     stripe_apm_pod = installer.sandbox.pod_dir('SpreedlyStripeAPM')
#     require File.join(stripe_apm_pod, 'scripts', 'cocoapods_stripe_bundle_patcher')
#     SpreedlyStripeAPM::CocoaPods.apply_stripe_bundle_patch(installer)
#   end

module SpreedlyStripeAPM
  module CocoaPods
    # SPM bundle name => { first_try_path:, embed_extra_paths:, insert_after_framework_line: }
    # embed_extra_paths: array of shell path strings for the elif try_paths
    BUNDLE_CONFIG = {
      'Stripe_StripeCore' => {
        first_try_path: '${BUILT_PRODUCTS_DIR}/StripeCoreBundle.bundle',
        embed_extra_paths: [
          '${BUILT_PRODUCTS_DIR}/StripeCoreBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripeCore/StripeCoreBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripeCore-StripeCoreBundle/StripeCoreBundle.bundle',
          '${PODS_CONFIGURATION_BUILD_DIR:-${BUILT_PRODUCTS_DIR}}/StripeCoreBundle.bundle',
          '${CONFIGURATION_BUILD_DIR}/StripeCoreBundle.bundle'
        ],
        insert_after_framework_line: '  install_framework "${BUILT_PRODUCTS_DIR}/StripeCore/StripeCore.framework"'
      },
      'Stripe_StripeUICore' => {
        first_try_path: '${BUILT_PRODUCTS_DIR}/StripeUICoreBundle.bundle',
        embed_extra_paths: [
          '${BUILT_PRODUCTS_DIR}/StripeUICoreBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripeUICore/StripeUICoreBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripeUICore-StripeUICoreBundle/StripeUICoreBundle.bundle',
          '${PODS_CONFIGURATION_BUILD_DIR:-${BUILT_PRODUCTS_DIR}}/StripeUICoreBundle.bundle',
          '${CONFIGURATION_BUILD_DIR}/StripeUICoreBundle.bundle'
        ],
        insert_after_framework_line: '  install_framework "${BUILT_PRODUCTS_DIR}/StripeUICore/StripeUICore.framework"'
      },
      'Stripe_StripePayments' => {
        first_try_path: '${BUILT_PRODUCTS_DIR}/StripePaymentsBundle.bundle',
        embed_extra_paths: [
          '${BUILT_PRODUCTS_DIR}/StripePaymentsBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePayments/StripePaymentsBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePayments-StripePaymentsBundle/StripePaymentsBundle.bundle',
          '${PODS_CONFIGURATION_BUILD_DIR:-${BUILT_PRODUCTS_DIR}}/StripePaymentsBundle.bundle',
          '${CONFIGURATION_BUILD_DIR}/StripePaymentsBundle.bundle'
        ],
        insert_after_framework_line: '  install_framework "${BUILT_PRODUCTS_DIR}/StripePayments/StripePayments.framework"'
      },
      'Stripe_StripePaymentsUI' => {
        first_try_path: '${BUILT_PRODUCTS_DIR}/StripePaymentsUIBundle.bundle',
        embed_extra_paths: [
          '${BUILT_PRODUCTS_DIR}/StripePaymentsUIBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePaymentsUI/StripePaymentsUIBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePaymentsUI-StripePaymentsUIBundle/StripePaymentsUIBundle.bundle',
          '${PODS_CONFIGURATION_BUILD_DIR:-${BUILT_PRODUCTS_DIR}}/StripePaymentsUIBundle.bundle',
          '${CONFIGURATION_BUILD_DIR}/StripePaymentsUIBundle.bundle'
        ],
        insert_after_framework_line: '  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentsUI/StripePaymentsUI.framework"'
      },
      'Stripe_Stripe3DS2' => {
        first_try_path: '${BUILT_PRODUCTS_DIR}/Stripe3DS2.bundle',
        embed_extra_paths: [
          '${BUILT_PRODUCTS_DIR}/Stripe3DS2.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePayments-Stripe3DS2/Stripe3DS2.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePayments-Stripe3DS2.bundle',
          '${BUILT_PRODUCTS_DIR}/Stripe3DS2-Stripe3DS2.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePayments/Stripe3DS2.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePayments/StripePayments-Stripe3DS2.bundle',
          '${PODS_CONFIGURATION_BUILD_DIR:-${BUILT_PRODUCTS_DIR}}/Stripe3DS2.bundle',
          '${CONFIGURATION_BUILD_DIR}/StripePayments-Stripe3DS2/Stripe3DS2.bundle'
        ],
        insert_after_framework_line: '  install_framework "${BUILT_PRODUCTS_DIR}/StripePayments/StripePayments.framework"',
        insert_after_bundle_line: '  install_bundle_with_name "${BUILT_PRODUCTS_DIR}/StripePaymentsBundle.bundle" "Stripe_StripePayments"' # 3DS2 line goes after Payments bundle line
      },
      'Stripe_StripePaymentSheet' => {
        first_try_path: '${BUILT_PRODUCTS_DIR}/StripePaymentSheetBundle.bundle',
        embed_extra_paths: [
          '${BUILT_PRODUCTS_DIR}/StripePaymentSheetBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePaymentSheet/StripePaymentSheetBundle.bundle',
          '${BUILT_PRODUCTS_DIR}/StripePaymentSheet-StripePaymentSheetBundle/StripePaymentSheetBundle.bundle',
          '${PODS_CONFIGURATION_BUILD_DIR:-${BUILT_PRODUCTS_DIR}}/StripePaymentSheetBundle.bundle',
          '${CONFIGURATION_BUILD_DIR}/StripePaymentSheetBundle.bundle'
        ],
        insert_after_framework_line: '  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentSheet/StripePaymentSheet.framework"'
      }
    }.freeze

    # Order for inject: Core, UICore, Payments, PaymentsUI, 3DS2 (after Payments), PaymentSheet. PaymentSheet is the "else" in shell.
    BUNDLE_ORDER = %w[
      Stripe_StripeCore
      Stripe_StripeUICore
      Stripe_StripePayments
      Stripe_StripePaymentsUI
      Stripe_Stripe3DS2
      Stripe_StripePaymentSheet
    ].freeze
    BUNDLE_ORDER_FOR_ELIF = (BUNDLE_ORDER - ['Stripe_StripePaymentSheet']).freeze

    # Run Script: simple copy_stripe_bundle(src_name, dest_name) - dest_name is SPM name
    RUN_SCRIPT_BUNDLES = [
      %w[StripePaymentSheetBundle Stripe_StripePaymentSheet],
      %w[StripeCoreBundle Stripe_StripeCore],
      %w[StripeUICoreBundle Stripe_StripeUICore],
      %w[StripePaymentsBundle Stripe_StripePayments],
      %w[StripePaymentsUIBundle Stripe_StripePaymentsUI],
      %w[StripePaymentsUI-StripePaymentsUIBundle Stripe_StripePaymentsUI]
    ].freeze

    class << self
      # @param installer [Pod::Installer]
      # @param options [Hash] optional :app_target_names (array) to restrict which targets get the Run Script; :project_path to override user project path
      def apply_stripe_bundle_patch(installer, options = {})
        installer.aggregate_targets.each do |aggregate_target|
          patch_frameworks_script(installer.sandbox.root, aggregate_target)
          add_run_script_phase(installer, aggregate_target, options)
        end
      end

      private

      def patch_frameworks_script(sandbox_root, aggregate_target)
        name = aggregate_target.name
        frameworks_script_path = File.join(sandbox_root, 'Target Support Files', name, "#{name}-frameworks.sh")
        return unless File.exist?(frameworks_script_path)

        script_content = File.read(frameworks_script_path)
        return unless script_content.include?('StripePaymentSheet') || script_content.include?('StripeCore')

        unless script_content.include?('install_bundle_with_name()')
          install_bundle_fn = build_install_bundle_fn
          marker = 'if [[ "$CONFIGURATION" == "Debug" ]]; then'
          script_content = script_content.sub(marker, install_bundle_fn + "\n" + marker)
        end

        BUNDLE_ORDER.each do |spm_name|
          config = BUNDLE_CONFIG[spm_name]
          next unless config

          bundle_line = "  install_bundle_with_name \"#{config[:first_try_path]}\" \"#{spm_name}\""
          next if script_content.include?(bundle_line)

          if config[:insert_after_bundle_line]
            script_content = script_content.gsub(config[:insert_after_bundle_line], config[:insert_after_bundle_line] + "\n" + bundle_line)
          else
            script_content = script_content.gsub(config[:insert_after_framework_line], config[:insert_after_framework_line] + "\n" + bundle_line)
          end
        end

        File.write(frameworks_script_path, script_content)
      end

      def build_install_bundle_fn
        parts = BUNDLE_ORDER_FOR_ELIF.each_with_index.map do |spm_name, idx|
          config = BUNDLE_CONFIG[spm_name]
          next nil unless config

          paths = config[:embed_extra_paths].map { |p| "      \"#{p}\"" }.join("\n")
          keyword = idx == 0 ? 'if' : 'elif'
          "  #{keyword} [ \"$dest_name\" = \"#{spm_name}\" ]; then\n    try_paths+=(\n#{paths}\n    )"
        end.compact

        # PaymentSheet is the "else" fallback
        payment_sheet_paths = BUNDLE_CONFIG['Stripe_StripePaymentSheet'][:embed_extra_paths].map { |p| "      \"#{p}\"" }.join("\n")
        else_block = "  else\n    try_paths+=(\n#{payment_sheet_paths}\n    )"

        <<~SHELL
          # Copy a resource bundle with a new name so SPM-built code (e.g. in SpreedlyStripeAPM.xcframework) can find it.
          # SPM looks in Bundle.main.resourceURL (app root) for bundleName.bundle, so copy to app root AND Frameworks.
          install_bundle_with_name() {
            if [ -z ${FRAMEWORKS_FOLDER_PATH+x} ]; then return 0; fi
            local dest_name="$2"
            local app_root="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
            local dest_fw="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/${dest_name}.bundle"
            local dest_root="${app_root}/${dest_name}.bundle"
            local try_paths=("$1")
          #{parts.join("\n")}
          #{else_block}
          fi
            local source_bundle=""
            for p in "${try_paths[@]}"; do
              if [ -d "$p" ]; then source_bundle="$p"; break; fi
            done
            if [ -z "$source_bundle" ]; then
              echo "warning: source bundle for $dest_name not found; Stripe flow may crash."
              return 0
            fi
            echo "Copying Stripe bundle for SPM compatibility: ${dest_name}.bundle (app root + Frameworks)"
            rm -rf "$dest_root" "$dest_fw"
            cp -R "$source_bundle" "$dest_root"
            cp -R "$source_bundle" "$dest_fw"
            for d in "$dest_root" "$dest_fw"; do
              [ -f "$d/Info.plist" ] && /usr/libexec/PlistBuddy -c "Set :CFBundleName $dest_name" "$d/Info.plist" 2>/dev/null || true
              code_sign_if_enabled "$d"
            done
          }
        SHELL
      end

      def add_run_script_phase(installer, aggregate_target, options)
        project_path = options[:project_path]
        unless project_path
          user_project = aggregate_target.user_project
          return unless user_project
          project_path = user_project.path
        end
        return unless File.exist?(project_path)

        pods_fw_name = "#{aggregate_target.name.gsub('-', '_')}.framework"
        phase_script = build_run_script_content(pods_fw_name)

        require 'xcodeproj'
        project = Xcodeproj::Project.open(project_path)
        app_target_names = options[:app_target_names]

        aggregate_target.user_targets.each do |user_target|
          next if app_target_names && !app_target_names.include?(user_target.name)
          next unless user_target.respond_to?(:build_phases)
          next unless user_target.build_phases.any? { |p| p.respond_to?(:name) && p.name.to_s.include?('Embed Pods') }

          phase = user_target.shell_script_build_phases.find { |p| p.name.to_s.include?('Copy Stripe bundle') || (p.respond_to?(:shell_script) && p.shell_script.to_s.include?('Stripe_StripePaymentSheet')) }
          unless phase
            phase = user_target.new_shell_script_build_phase('Copy Stripe bundle for SPM')
            embed_idx = user_target.build_phases.index { |p| p.respond_to?(:name) && p.name.to_s.include?('Embed Pods') }
            if embed_idx
              user_target.build_phases.delete(phase)
              user_target.build_phases.insert(embed_idx + 1, phase)
            end
          end
          phase.shell_script = phase_script
          phase.run_only_for_deployment_postprocessing = '0'
        end
        project.save
      rescue => e
        puts "Could not add Run Script phase: #{e.message}"
      end

      def build_run_script_content(pods_fw_name)
        copy_calls = RUN_SCRIPT_BUNDLES.map { |src, dest| "      copy_stripe_bundle \"#{src}\" \"#{dest}\"" }.join("\n")
        # 3DS2 block uses generic APP/FW; search paths include BUILT_PRODUCTS_DIR and find fallback
        <<~SCRIPT
          APP="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
          FW="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
          copy_stripe_bundle() {
            local src_name="$1" dest_name="$2"
            local dest_root="${APP}/${dest_name}.bundle" dest_fw="${FW}/${dest_name}.bundle"
            rm -rf "$dest_root" "$dest_fw"
            local src=""
            for c in "${APP}/${src_name}.bundle" "${APP}/Frameworks/${src_name}.bundle" "${APP}/Frameworks/#{pods_fw_name}/Resources/${src_name}.bundle" "${APP}/Frameworks/#{pods_fw_name}/${src_name}.bundle" "${FW}/${src_name}.bundle"; do
              if [ -d "$c" ]; then src="$c"; break; fi
            done
            if [ -n "$src" ]; then
              cp -R "$src" "$dest_root"
              [ -f "$dest_root/Info.plist" ] && /usr/libexec/PlistBuddy -c "Set :CFBundleName $dest_name" "$dest_root/Info.plist" 2>/dev/null || true
              cp -R "$src" "$dest_fw"
              [ -f "$dest_fw/Info.plist" ] && /usr/libexec/PlistBuddy -c "Set :CFBundleName $dest_name" "$dest_fw/Info.plist" 2>/dev/null || true
              echo "Stripe SPM bundle: ${dest_name}.bundle (app root + Frameworks)"
            else
              echo "warning: ${src_name}.bundle not found; Stripe may crash"
            fi
          }
          #{copy_calls}
          D3DEST="Stripe_Stripe3DS2"
          D3ROOT="${APP}/${D3DEST}.bundle"
          D3FW="${FW}/${D3DEST}.bundle"
          rm -rf "$D3ROOT" "$D3FW"
          src=""
          for c in "${BUILT_PRODUCTS_DIR}/Stripe3DS2.bundle" "${BUILT_PRODUCTS_DIR}/StripePayments-Stripe3DS2/Stripe3DS2.bundle" "${APP}/Stripe3DS2.bundle" "${APP}/StripePayments-Stripe3DS2.bundle" "${APP}/Frameworks/Stripe3DS2.bundle" "${APP}/Frameworks/StripePayments-Stripe3DS2.bundle" "${APP}/Frameworks/#{pods_fw_name}/Resources/Stripe3DS2.bundle" "${APP}/Frameworks/#{pods_fw_name}/Resources/StripePayments-Stripe3DS2.bundle" "${FW}/Stripe3DS2.bundle" "${FW}/StripePayments-Stripe3DS2.bundle" "${BUILT_PRODUCTS_DIR}/StripePayments-Stripe3DS2.bundle" "${BUILT_PRODUCTS_DIR}/StripePayments-Stripe3DS2/StripePayments-Stripe3DS2.bundle" "${BUILT_PRODUCTS_DIR}/Stripe3DS2-Stripe3DS2.bundle"; do
            if [ -d "$c" ]; then src="$c"; break; fi
          done
          if [ -z "$src" ] && [ -n "${BUILD_DIR}" ]; then
            found=$(find "${BUILD_DIR}" -maxdepth 5 -type d -name "*Stripe*3DS2*.bundle" 2>/dev/null | head -1)
            [ -n "$found" ] && src="$found"
          fi
          if [ -z "$src" ] && [ -n "${BUILT_PRODUCTS_DIR}" ]; then
            found=$(find "${BUILT_PRODUCTS_DIR}" -maxdepth 5 -type d \\( -name "Stripe3DS2.bundle" -o -name "StripePayments-Stripe3DS2.bundle" -o -name "Stripe3DS2-Stripe3DS2.bundle" -o -name "*Stripe*3DS2*.bundle" \\) 2>/dev/null | head -1)
            [ -n "$found" ] && src="$found"
          fi
          if [ -n "$src" ]; then
            cp -R "$src" "$D3ROOT"
            [ -f "$D3ROOT/Info.plist" ] && /usr/libexec/PlistBuddy -c "Set :CFBundleName $D3DEST" "$D3ROOT/Info.plist" 2>/dev/null || true
            cp -R "$src" "$D3FW"
            [ -f "$D3FW/Info.plist" ] && /usr/libexec/PlistBuddy -c "Set :CFBundleName $D3DEST" "$D3FW/Info.plist" 2>/dev/null || true
            echo "Stripe SPM bundle: ${D3DEST}.bundle (from $(basename "$src"))"
          else
            echo "warning: Stripe_Stripe3DS2 source bundle not found; 3DS may crash. BUILD_DIR=${BUILD_DIR:-unset} BUILT_PRODUCTS_DIR=${BUILT_PRODUCTS_DIR:-unset}"
          fi
        SCRIPT
      end
    end
  end
end
