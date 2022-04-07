require 'json'

lcp = Dir.glob('lighthouse/*.json')
  .reject { |file| file =~ /latest/ }
  .sort
  .reverse
  .map do |filename|
    date = filename[/\d{2}-\d{2}-\d{2}/]
    metrics = JSON.parse(File.read(filename), symbolize_names: true)

    { date: date, metric: metrics[:audits][:'largest-contentful-paint'] }
  end

table_head = []
table_values = []
table_seperator = lcp.map { |_| '---' }.join('|')

lcp.each_with_index do |metric, index|
  day_before = lcp[index + 1]

  table_head << metric[:date]

  label = ""
  label += "❌ " if day_before && metric[:metric][:numericValue] > day_before[:metric][:numericValue]
  label += "✅ " if day_before && metric[:metric][:numericValue] < day_before[:metric][:numericValue]
  label += metric[:metric][:displayValue]

  table_values << label
end

for_render = [ table_head.join(' | '), table_seperator, table_values.join(' | ') ].join("\n")

readme = File.read('README.md').gsub(%r{<!-- lcp -->.*<!-- /lcp -->}m, "<!-- lcp -->\n#{for_render}\n<!-- /lcp -->")
File.write('README.md', readme)
