# frozen_string_literal: true
require 'global' unless defined?(T)
require 'formulary'
require 'tap'

# Init module
module Init
  module_function

  # Checks if Formula or Cask is installed and Install it, also taps it.
  class Satisfy
    # Application Code
    # JetBrains API application short code
    # @return [String]
    attr_reader :formula

    # Application Code
    # JetBrains API application short code
    # @return [String]
    attr_reader :name

    # Application Code
    # JetBrains API application short code
    # @return [String | Pathname]
    attr_reader :ref

    # Creates an Instance of the class
    #
    # @param [String] ref formula/cask name or file path
    # @param [bool] formula true if ref is a formula, false for cask
    # @return [void]
    def initialize(ref, formula: true)
      @name = ref.to_s.downcase
      @formula = formula
      @ref = ref
    end
  end

  # Checks if any version of formula is installed.
  #
  #   exists?("Formula/name.rb")
  #
  # @param [String | Pathname] ref formula name or path
  # @return [T::Boolean] true if formula is installed
  def exists?
    tap!
    if @formula
      instance.any_version_installed?
    else
      instance.installed?
    end
  end

  # Returns {Formulary} or {Cask} depending on {@formula}
  # @return [Formulary, Formula, Cask] true if formula is installed
  def instance
    unless defined?(@instance)
      @instance = if @formula
                    Formulary.factory(@name)
                  else
                    Cask::CaskLoader.load(@name)
                  end
    end
    @instance
  end

  # Install Cask or Formula if not Installed (and its container tap if not installed).
  #
  # @return [T::Boolean] true if formula is installed
  def satisfy
    if @formula
      begin
        Homebrew::Install.install_formulae(instance, quiet: true) unless exists?
      rescue StandardError
        odie "Formula '#{@name}'"
      end
      exists?
    else
      tap!
      cask = Cask::CaskLoader.load(@name)
      unless cask.installed?
        begin
          Cask::Installer.new(@cask, quarantine: false, quiet: true).install
        rescue StandardError
          odie "Cask '#{@name}'"
        end
      end
      cask.installed?
    end
  end

  # Tap it if not tapped.
  #
  # @return [nil]
  def tap!
    return unless File.exist?(@ref)
    return unless @name !~ HOMEBREW_TAP_FORMULA_REGEX

    tap = Tap.fetch(Regexp.last_match(1), Regexp.last_match(2))
    tap.install(quiet: true) unless tap.installed?
  end
end
