require 'spec_helper'

describe Jobs::Receive do
  before do
    @user = make_user
    @person = Factory(:person)
    @xml = '<xml></xml>'
    User.stub(:find){ |id|
      if id == @user.id
        @user
      else
        nil
      end
    }
  end

  it 'calls receive' do
    zord_mock = mock()
    zord_mock.should_receive(:parse_and_receive).with(@xml)
    Postzord::Receiver.should_receive(:new).with(@user, anything).and_return(zord_mock)
    Jobs::Receive.perform(@user.id, @xml, @person.id)
  end
end
