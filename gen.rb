#!/usr/bin/env ruby
#encoding=utf-8
require 'erb'
require 'yaml'
require 'ruby-pinyin'
$src_dir        = "landmarks"
$template_file  = "template.erb"
$type_file      = "types.yaml"
$planet_file    = "planets.yaml"

$template = ERB.new File.read $template_file

YAML.load_file($planet_file).each do |planet_info|
  $planet         = planet_info['planet']
  $index_file     = planet_info['index_file']
  $desc_dir       = planet_info['desc_dir']
  $desc_pub       = planet_info['desc_pub']
  indices = YAML.load_file $index_file  
  
  Dir[$src_dir+"/**/*.ymd"].each do |f|
    meta, desc = YAML.load_stream File.open(f, "r:bom|utf-8"){|f| f.read}
    next if $planet != meta['planet']
    alt = indices.detect{|x| x['name'] == meta['title']}
    next if !alt.nil? && !alt['version'].nil? && alt['version'] > meta['version']
    indices.delete alt
    filename = PinYin.of_string(meta['title'], true).join("_") +".md"
    desc_file  = $desc_dir + "/" + filename
    @desc = desc
    @authors = meta['authors']
    File.write desc_file, $template.result
    indices.push(
      'name' => meta['title'],
      'pos' => (meta['pos'].nil? ? alt['pos'] : ({
        'lat' => -meta['pos']['lat'],
        'lng' =>  meta['pos']['lng']
      })),
      'desc' => $desc_pub + "/" + filename,
      'template' => meta['type'],
      'version' => meta['version']
    )
  end
  
  File.write $index_file, indices.to_yaml

end
