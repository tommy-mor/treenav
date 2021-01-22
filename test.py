def find_pages(_, page):
    print('visiting ', page)
    visited.add(page)
    # examples of page : 'b:chatapp'
    newnode = node(page)
    3
    4
    # @todo add page body to this.

    links = wiki.pages.links(page)
    children = []
    for link in links:
        # ignore links that are not internal
        if link['type'] == 'local':
            newpage = link['page']
            if newpage not in visited:
                children.append(find_pages(None, newpage))
        else:
            print('ignoring link to ', link['page'])

    for child in children:
        newnode.append(child)

    return newnode
