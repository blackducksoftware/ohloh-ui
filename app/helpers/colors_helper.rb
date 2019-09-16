# frozen_string_literal: true

module ColorsHelper
  LANGUAGE_COLORS = {
    'actionscript' => 'E3491A',
    'ada' => 'FAE028',
    'assembler' => '333333',
    'augeas' => 'CCCCCC',
    'awk' => '4D8D94',
    'bat' => 'AAAAAA',
    'boo' => 'FCF050',
    'clearsilver' => '26A491',
    'clojure' => 'DB5855',
    'cncpp' => 'FF8F00',
    'coffeescript' => '244776',
    'c' => 'FF8F00',
    'coq' => 'CCCCCC',
    'cpp' => 'F35F1F',
    'csharp' => '4096EE',
    'css' => 'FF1A00',
    'dmd' => 'EC2E24',
    'dylan' => '822C2C',
    'ec' => 'CCCCCC',
    'eiffel' => '946D57',
    'emacslisp' => '2B6B24',
    'erlang' => '6A2CC7',
    'factor' => '636746',
    'forth' => '341708',
    'fortranfixed' => '4d41b1',
    'fortranfree' => '4d41b1',
    'fsharp' => 'B845FC',
    'groovy' => 'C72C2C',
    'golang' => '8D04EB',
    'haskell' => '007B7C',
    'haxe' => '346D51',
    'html' => '47A400',
    'java' => '9A63AD',
    'javascript' => 'A4007E',
    'lisp' => '93D290',
    'logtalk' => 'CCCCCC',
    'lua' => 'A42E00',
    'matlab' => 'A46400',
    'objective_c' => 'C7932C',
    'objective_j' => 'FF0C5A',
    'ocaml' => '3BE133',
    'pascal' => 'D15600',
    'perl' => 'D2C690',
    'php' => '356AA0',
    'pike' => '066AB2',
    'puppet' => 'CC5555',
    'python' => '4A246B',
    'r' => '198CE7',
    'racket' => 'AE17FF',
    'rebol' => '358A5B',
    'rexx' => '00A44B',
    'ruby' => 'A40011',
    'rust' => '75000D',
    'scala' => '7DD3B0',
    'scheme' => '90C0D2',
    'scilab' => 'CCCCCC',
    'shell' => '777777',
    'smalltalk' => '596706',
    'sql' => '493625',
    'tcl' => 'D290A8',
    'tex' => '000080',
    'vala' => '729FCF',
    'vhdl' => '543978',
    'vim' => '199C4B',
    'visualbasic' => '2C5DC7',
    'xml' => '555555',
    'xmlschema' => '556677',
    'xslt' => '556655'
  }.freeze

  def language_color(name)
    LANGUAGE_COLORS[name] || 'EEE'
  end

  BLACK_TEXT_LANGUAGES = %w[ada augeas bat boo c cncpp coq ec html lisp logtalk objective_c
                            ocaml perl r scala scheme scilab tcl vala].freeze

  def language_text_color(name)
    BLACK_TEXT_LANGUAGES.include?(name) || language_color(name) == 'EEE' ? '000' : 'FFF'
  end
end
