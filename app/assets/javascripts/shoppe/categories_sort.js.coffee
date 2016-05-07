$ ->
  sortableRoot = $('table[role=product-categories]')
  return unless sortableRoot.length

  arrayUnique = (arr) ->
    arr.filter (e, i, a) -> a.lastIndexOf(e) == i

  postPositions = (ary) ->
    $.ajax
      url: window.location.href + '/positions'
      method: 'PUT'
      dataType: 'json'
      data:
        positions: ary

  $(sortableRoot).sortable
    connectWith: 'tbody'
    items: 'tr[data-scope="root"]'
    axis: 'y'
    update: (ev, ui) ->
      positions = $(this).sortable 'toArray'
      postPositions positions


  subListsAll = $.map $('td [data-scope]'), (item) -> $(item).data('scope')
  subList = arrayUnique subListsAll

  subList.forEach (i) ->
    id = "[data-scope=#{i}]"
    parent = $(id).parent()

    $(parent).sortable
      # connectWith: parent
      items: id
      axis: 'y'
      update: (ev, ui) ->
        positions = $(this).sortable 'toArray'
        postPositions positions
