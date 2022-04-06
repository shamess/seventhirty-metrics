require 'json'

lcp = Dir.glob('lighthouse/*.json')
  .reject { |file| file == 'latest.json' }
  .sort
  .map do |filename|
    metrics = JSON.parse(File.read(filename))

    metrics['audits']['largest-contentful-paint']
  end

previousMetric = nil

labels = lcp.map do |metric|
  label = ""

  label += "❌ " if previousMetric && metric['numericValue'] > previousMetric['numericValue']
  label += "✅ " if previousMetric && metric['numericValue'] < previousMetric['numericValue']
  label += metric['displayValue']

  previousMetric = metric

  label
end

forRender = '|' + labels.reverse.join(' | ') + '|'

readme = File.read('README.md').gsub(%r{<!-- lcp -->.*<!-- /lcp -->}, "<!-- lcp -->#{forRender}<!-- /lcp -->")
File.write('README.md', readme)
