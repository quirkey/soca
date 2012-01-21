require 'helper'

class TestCompassPlugin < Test::Unit::TestCase
  def app_path(relative='')
    File.expand_path(@test_app_dir + '/' + relative)
  end

  context 'compass plugin' do
    setup do
      @pusher = Soca::Pusher.new(app_path)
    end

    context 'given no options' do
      should 'invoke compass compiler with default options' do
        Compass::Compiler.expects(:new).
          with(@test_app_dir, app_path('sass'), app_path('css'), anything).
          returns(mock(:run => true))

        @plugin = Soca::Plugins::Compass.new(@pusher)
        @plugin.before_build
      end
    end

    context 'given a from option' do
      should 'invoke compass compiler with provided from option' do
        Compass::Compiler.expects(:new).
          with(@test_app_dir, app_path('app/sass'), app_path('css'), anything).
          returns(mock(:run => true))

        @plugin = Soca::Plugins::Compass.new(@pusher, :from => 'app/sass')
        @plugin.before_build
      end
    end

    context 'given a to option' do
      should 'invoke compass compiler with provided to option' do
        Compass::Compiler.expects(:new).
          with(@test_app_dir, app_path('sass'), app_path('snoop_dogg/css'), anything).
          returns(mock(:run => true))

        @plugin = Soca::Plugins::Compass.new(@pusher, :to => 'snoop_dogg/css')
        @plugin.before_build
      end
    end

    context 'given a from option and a to option' do
      should 'invoke compas compiler with provided from and to options' do
        Compass::Compiler.expects(:new).
          with(@test_app_dir, app_path('app/sass'), app_path('app/css'), anything).
          returns(mock(:run => true))

        @plugin = Soca::Plugins::Compass.new(@pusher, :from => 'app/sass', :to => 'app/css')
        @plugin.before_build
      end
    end
  end
end
