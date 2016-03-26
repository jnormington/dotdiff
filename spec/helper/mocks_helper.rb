module MocksHelper
  class MockPage
    def evaluate_script(cmd); end
    def save_screenshot(file); end
  end

  class MockElement
    def path; end
  end
end
