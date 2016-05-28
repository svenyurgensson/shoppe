$ ->
  sortableProductsRoot = $('table[role=products]')
  return unless sortableProductsRoot.length

  arrayUnique = (arr) ->
    arr.filter (e, i, a) -> a.lastIndexOf(e) == i

  postPositions = (ary) ->
    $.ajax
      url: window.location.pathname + '/positions'
      method: 'PUT'
      dataType: 'json'
      data:
        positions: ary

  $.map $('[data-scope=root]'), (parent) ->
    pid = $(parent).attr('id')
    $(parent).disableSelection()
    $(parent).find('tbody').sortable
      #items: '> tr[data-scope="#{pid}"]'
      axis: 'y'
      helper: (e, ui) ->
        ui.children().each ()->
          $(this).width($(this).width())
        ui
      update: (ev, ui) ->
        positions = $(this).sortable 'toArray'
        postPositions positions
