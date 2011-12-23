require 'helper'

describe PryExceptionExplorer do

  after do
    EE.instance_eval do
      @exception_intercepted = false
    end
  end

  describe "PryExceptionExplorer#intercept" do
    describe "class" do
      describe "first frame" do
        it  "should intercept exception based on first frame's method name" do
          EE.intercept { |frame, ex| frame.klass == Toad }
          Ratty.new.ratty
          EE.exception_intercepted?.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.klass == Ratty }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted?.should == false
        end
      end

      describe "second frame" do
        it  "should intercept exception based on second frame's method name" do
          EE.intercept { |frame, ex| frame.prev.klass == Weasel }
          Ratty.new.ratty
          EE.exception_intercepted?.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.klass == Toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted?.should == false
        end
      end

      describe "third frame" do
        it  "should intercept exception based on third frame's method name" do
          EE.intercept { |frame, ex| frame.prev.prev.klass == Ratty }
          Ratty.new.ratty
          EE.exception_intercepted?.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.prev.klass == Toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted?.should == false
        end
      end

    end

    describe "method_name" do
      describe "first frame" do
        it  "should intercept exception based on first frame's method name" do
          EE.intercept { |frame, ex| frame.method_name == :toad }
          Ratty.new.ratty
          EE.exception_intercepted?.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.method_name == :ratty }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted?.should == false
        end
      end

      describe "second frame" do
        it  "should intercept exception based on second frame's method name" do
          EE.intercept { |frame, ex| frame.prev.method_name == :weasel }
          Ratty.new.ratty
          EE.exception_intercepted?.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.method_name == :toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted?.should == false
        end
      end

      describe "third frame" do
        it  "should intercept exception based on third frame's method name" do
          EE.intercept { |frame, ex| frame.prev.prev.method_name == :ratty }
          Ratty.new.ratty
          EE.exception_intercepted?.should == true
        end

        it  "should NOT intercept exception if method name doesn't match" do
          EE.intercept { |frame, ex| frame.prev.prev.method_name == :toad }
          begin
            Ratty.new.ratty
          rescue Exception => ex
            ex.is_a?(RuntimeError).should == true
          end
          EE.exception_intercepted?.should == false
        end
      end

    end

  end
end
