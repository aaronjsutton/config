def vz [...query: string] {
    ^fzf -q ($query | str join ' ') --bind 'enter:become(nvim {})'
}
