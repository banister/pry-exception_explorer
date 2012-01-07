require 'helper'

class << EE
  attr_accessor :exception_intercepted
end

prev_wrap_state = PryExceptionExplorer.wrap_active
PryExceptionExplorer.wrap_active = false

describe PryExceptionExplorer do

  before do
    PryExceptionExplorer.wrap_active = false
    EE.exception_intercepted = false
    Pry.config.input = StringIO.new("EE.exception_intercepted = true\ncontinue-exception")
    Pry.config.output = StringIO.new
  end

  after do
    Pry.config.input.rewind
  end

  describe "PryExceptionExplorer.intercept" do
    describe "special case exception-only syntax" do

      describe "single exception" do
        it 'should intercept provided exceptions when given parameters (and no block)' do
          my_error = Class.new(StandardError)
          EE.intercept(my_error)
          raise my_error
          EE.exception_intercepted.should == true
        end

        it 'should NOT intercept provided exceptions when not matched' do
          my_error = Class.new(StandardError)
          EE.intercept(my_error)

          begin
            raise RuntimeError
          rescue => ex
            ex.is_a?(RuntimeError).should == true
          end
        end
      end

      describe "multiple exceptions" do
        it 'should intercept provided exceptions when given parameters (and no block)' do
          errors = Array.new(3) { Class.new(StandardError) }
          EE.intercept(*errors)

          errors.each do |my_error|
            raise my_error
            EE.exception_intercepted.should == true
            EE.exception_intercepted  = false
            Pry.config.input.rewind
          end
        end

        it 'should NOT intercept provided exceptions when not matched' do
          errors = Array.new(3) { Class.new(StandardError) }

          EE.intercept(*errors)

          errors.each do |my_error|
            begin
              raise RuntimeError
            rescue => ex
              ex.is_a?(RuntimeError).should == true
            end
          end
        end
      end

    end

    describe "class" do
      describe "first frame" do
        it  "should intercept exception based on first frame's class" do
          EE.intercept { |frame, ex| frame.klass == Toad }
          Ratty.new.ratty
          EE.exception_intercepted.should == true
        end

        it  "should NOT intercept exception if class doesn't match" do
          EE.intercept { |frame, ex| frame.klass == Ratty }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted.should == false
        end
      end

      describe "second frame" do
        it  "should intercept exception based on second frame's method name" do
          EE.intercept { |frame, ex| frame.prev.klass == Weasel }
          Ratty.new.ratty
          EE.exception_intercepted.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.klass == Toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted.should == false
        end
      end

      describe "third frame" do
        it  "should intercept exception based on third frame's method name" do
          EE.intercept { |frame, ex| frame.prev.prev.klass == Ratty }
          Ratty.new.ratty
          EE.exception_intercepted.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.prev.klass == Toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted.should == false
        end
      end

    end

    describe "method_name" do
      describe "first frame" do
        it  "should intercept exception based on first frame's method name" do
          EE.intercept { |frame, ex| frame.method_name == :toad }
          Ratty.new.ratty
          EE.exception_intercepted.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.method_name == :ratty }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted.should == false
        end
      end

      describe "second frame" do
        it  "should intercept exception based on second frame's method name" do
          EE.intercept { |frame, ex| frame.prev.method_name == :weasel }
          Ratty.new.ratty
          EE.exception_intercepted.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.method_name == :toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted.should == false
        end
      end

      describe "third frame" do
        it  "should intercept exception based on third frame's method name" do
          EE.intercept { |frame, ex| frame.prev.prev.method_name == :ratty }
          Ratty.new.ratty
          EE.exception_intercepted.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.prev.method_name == :toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted.should == false
        end
      end

    end

  end
end

PryExceptionExplorer.wrap_active = prev_wrap_state