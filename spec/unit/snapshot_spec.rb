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

  describe '#resave_cropped_file' do
    it 'calls resave_base_file' do
      expect(subject).to receive(:resave_base_file).with(:cropped).once
      subject.resave_cropped_file
    end
  end

  describe '#resave_fullscreen_file' do
    it 'calls resave_base_file' do
      expect(subject).to receive(:resave_base_file).with(:fullscreen).once
      subject.resave_fullscreen_file
    end
  end

  %w(fullscreen cropped).each do |version|
    describe "#resave_base_file with #{version}" do
      let(:base_file) { '/home/se/images/testy/CancellationDialog.png' }
      let(:fullscreen_file) { '/tmp/T/testy/CancellationDialog.png' }
      let(:cropped_file) { '/tmp/T/testy/CancellationDialog_cropped.png' }
      let(:opts) {{ force: true }}

      before do
        allow(File).to receive(:exists?).and_return(true)
        expect(FileUtils).to receive(:mkdir_p).with(DotDiff.image_store_path + '/testy')
      end

      it 'calls mkdir_p to ensure subdir exist' do
        subject.send(:resave_base_file, version)
      end

      context 'when overwrite on resave' do
        before { DotDiff.overwrite_on_resave = true }

        it 'calls FileUtils with force option' do
          allow(subject).to receive(:capture_from_browser).and_return(subject.fullscreen_file)
          expect(FileUtils).to receive(:mv).with(self.send("#{version}_file"), base_file, opts)

          subject.send(:resave_base_file, version)
        end
      end

      context 'when overwrite on resave false' do
        before { DotDiff.overwrite_on_resave = false }

        let(:altered_file) { "#{base_file}.r2" }

        it 'calls FileUtils with an altered file name destination' do
          expect(FileUtils).to receive(:mv).with(self.send("#{version}_file"), altered_file, opts)
          subject.send(:resave_base_file, version)
        end

        it 'creates base_file without r2 when original file doesnt exist' do
          allow(File).to receive(:exists?).and_return(false)
          expect(FileUtils).to receive(:mv).with(self.send("#{version}_file"), base_file, opts)
          subject.send(:resave_base_file, version)
        end
      end
    end
  end
end
