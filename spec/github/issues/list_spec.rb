# encoding: utf-8

require 'spec_helper'

describe Github::Issues, '#list' do
  let(:request_path) { "/issues" }
  let(:body) { fixture('issues/issues.json') }
  let(:status) { 200 }

  before {
    stub_get(request_path).to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for(subject) }

  context "resource found" do

    it { should respond_to(:all) }

    it "should get the resources" do
      subject.list
      a_get(request_path).should have_been_made
    end

    it_should_behave_like 'an array of resources' do
      let(:requestable) { subject.list }
    end

    it "should get issue information" do
      issues = subject.list
      issues.first.title.should == 'Found a bug'
    end

    it "should yield to a block" do
      yielded = []
      result = subject.list { |obj| yielded << obj }
      yielded.should == result
    end
  end

  context 'for a given organization' do
    let(:org) { 'github' }
    let(:request_path) { "/orgs/#{org}/issues" }

    it 'should get the resources' do
      subject.list :org => org
      a_get(request_path).should have_been_made
    end
  end

  context 'for an user' do
    let(:request_path) { "/user/issues" }

    it 'should get the resources' do
      subject.list :user
      a_get(request_path).should have_been_made
    end
  end

  context "for a repository" do
    let(:user)   { 'peter-murach' }
    let(:repo)   { 'github' }
    let(:request_path) { "/repos/#{user}/#{repo}/issues" }

    it "should get the resources" do
      subject.list :user => user, :repo => repo
      a_get(request_path).should have_been_made
    end

    it_should_behave_like 'an array of resources' do
      let(:requestable) { subject.list :user => user, :repo => repo }
    end

    it "should get repository issue information" do
      repo_issues = subject.list :user => user, :repo => repo
      repo_issues.first.title.should == 'Found a bug'
    end

    it "should yield to a block" do
      yielded = []
      result = subject.list(:user => user, :repo => repo) { |obj| yielded << obj }
      yielded.should == result
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.list }
  end
end # list
