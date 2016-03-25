require 'spec_helper'

RSpec.describe DotDiff::Snapshot do
  let(:options) {{ filename: 'CancellationDialog', subdir: 'testy', page: MockPage.new }}
  subject { DotDiff::Snapshot.new(options) }

  before do
    allow(Dir).to receive(:tmpdir).and_return('/tmp/T')
    allow(DotDiff).to receive(:image_store_path).and_return('/home/se/images')
  end

  describe '#initialize' do
    it 'initializes base_filename, subdir and rootdir' do
      expect(subject.base_filename).to eq 'CancellationDialog.png'
      expect(subject.subdir).to eq 'testy'
      expect(subject.rootdir).to eq '/home/se/images'
    end
  end

  describe '#fullscreen_file' do
    it 'returns fullscreen file path with subdir' do
      expect(subject.fullscreen_file).to eq '/tmp/T/testy/CancellationDialog.png'
    end
  end

  describe '#cropped_file' do
    it 'returns cropped file path with subdir' do
      expect(subject.cropped_file).to eq '/tmp/T/testy/CancellationDialog_cropped.png'
    end
  end

  describe '#basefile' do
    it 'returns the basefile to compare to' do
      expect(subject.basefile).to eq '/home/se/images/testy/CancellationDialog.png'
    end
  end

  describe '#base_filename' do
    it 'returns file name with extension' do
      expect(subject.base_filename).to eq 'CancellationDialog.png'
    end

    it 'returns the name without the extension' do
      expect(subject.base_filename(false)).to eq 'CancellationDialog'
    end
  end

  describe '#capture_from_browser' do
    it 'calls save_screenshot with temporary location' do
      expect(subject).to receive(:fullscreen_file).and_return('/tmp/T/basefile.png').once
      expect(subject.page).to receive(:save_screenshot).with('/tmp/T/basefile.png').once
      subject.capture_from_browser
    end
  end
end
