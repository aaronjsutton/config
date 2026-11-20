# zenwritten-style colours (matches the Ghostty theme): mostly the terminal
# foreground, emphasis from bold/italic, few accents. Only ANSI palette names,
# so it follows Ghostty's light/dark switch. `light_gray` is palette 15, a
# readable dim grey in both variants; zenwritten's dark_gray (palette 8) is
# nearly invisible on the dark background.
$env.config.color_config = ($env.config.color_config | merge {
    separator: light_gray
    header: {attr: b}
    row_index: light_gray
    hints: light_gray
    empty: light_gray
    nothing: light_gray
    leading_trailing_space_bg: {attr: n}
    search_result: {attr: r}

    bool: cyan
    int: default
    float: default
    filesize: default
    duration: default
    range: default
    datetime: magenta
    string: default
    binary: light_gray
    cell-path: default
    record: default
    list: default
    closure: default
    glob: default

    # Syntax highlighting while typing.
    shape_internalcall: {attr: b}
    shape_external: {fg: red attr: b}  # not found on PATH
    shape_external_resolved: {attr: b}
    shape_keyword: {attr: b}
    shape_custom: {attr: b}
    shape_externalarg: default
    shape_flag: blue
    shape_variable: magenta
    shape_vardecl: magenta
    shape_string: {attr: i}
    shape_string_interpolation: {attr: i}
    shape_raw_string: {attr: i}
    shape_rawstring: {attr: i}
    shape_glob_interpolation: {attr: i}
    shape_globpattern: cyan
    shape_filepath: cyan
    shape_directory: cyan
    shape_int: default
    shape_float: default
    shape_bool: cyan
    shape_datetime: magenta
    shape_nothing: light_gray
    shape_operator: light_gray
    shape_pipe: light_gray
    shape_redirection: light_gray
    shape_signature: {attr: b}
    shape_block: default
    shape_closure: default
    shape_list: default
    shape_record: default
    shape_table: default
    shape_range: default
    shape_binary: light_gray
    shape_literal: blue
    shape_matching_brackets: {attr: u}
    shape_garbage: {fg: red attr: u}
})
