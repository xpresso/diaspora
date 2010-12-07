require "spec_helper"

describe I18n::Backend::Inflector do
  describe "#translate" do
    after do
      I18n.locale = :en
    end
    context "language doesn't require inflection" do
      it "returns a non-inflected string" do
        I18n.locale = :en
        I18n.translate("are_you_sure").should == "Are you sure?"
        I18n.translate("are_you_sure", :inflection => "Ignore me!").should == "Are you sure?"
      end
    end
    context "language requires inflection" do
      context "no inflection specified" do
        context "on a non-inflected string" do
          it "returns the unmodified string" do
            I18n.locale = :pl
            I18n.translate("account").should == "Konto"
          end
        end
        context "on an inflected string" do
          it "returns the translation for the default inflection" do
            I18n.locale = :pl
            I18n.translate("are_you_sure").should == "Na pewno? neuter"
          end

          it "returns a translation error if there's no default inflection" do
            I18n.locale = :nodefault
            I18n.translate("are_you_sure").should =~ /translation missing/
          end
        end
      end
      context "inflection specified" do
        context "on a non-inflected string" do
          it "returns the unmodified string" do
            I18n.locale = :pl
            I18n.translate("account", :inflection => "feminine").should == "Konto"
          end
        end
        context "on an inflected string" do
          it "returns the translation for the specified inflection" do
            I18n.locale = :pl
            I18n.translate("are_you_sure", :inflection => "masculine").should == "Na pewno? masculine"
          end

          it "returns a translation error if you pass a nonexistant inflection" do
            I18n.locale = :pl
            I18n.translate("are_you_sure", :inflection => "nonesuch").should =~ /translation missing/
          end
        end
      end
    end
  end
end