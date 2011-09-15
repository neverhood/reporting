// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g,"");
};

Array.prototype.equals = function(array) {
    var result = true;

    for ( element in this ) {
        if ( this[element] != array[element] ) {
            result = false;
            break;
        }
    }

    return result;
};

var nil = null; // :)

$(document).ready(function() {

    var api = $.reporting = {
        version: 0,
        reportTypes: [],
        reportFields: [],
        reportFieldsAmount: 0,
        loader: ("<img class='loader' src='/images/loader.gif' />"),
        utils: {},
        selectors: {},
        filtersRequiringInput: ['equals', 'starts_with', 'ends_with', 'contains', 'less_than', 'more_than', 'less_or_equal', 'more_or_equal'],
        notCombineAbleFilters: {
            is_null: ['equals', 'starts_with', 'ends_with', 'contains', 'less_than', 'more_than', 'is_not_null'],
            is_not_null: ['equals', 'starts_with', 'ends_with', 'contains', 'less_than', 'more_than', 'is_null'],
            starts_with: ['equals', 'is_null', 'is_not_null'],
            ends_with: ['equals', 'is_null', 'is_not_null'],
            equals: ['starts_with', 'ends_with', 'less_than', 'more_than', 'contains'],
            contains: ['is_null', 'is_not_null', 'equals'],
            less_than: ['is_null', 'is_not_null', 'equals'],
            more_than: ['is_null', 'is_not_null', 'equals']
        }
    };

    var selectors = api.selectors,
            utils = api.utils;

    selectors.reportFieldsContainer = $('div#report-fields');
    selectors.reportFields = $(selectors.reportFieldsContainer).find('input[type="checkbox"]');
    selectors.orderBy = $('select#report_order_by');
    selectors.filtersForFields = $('select.filter-for-field');
    selectors.filtersContainer = $('#report-filters');

    utils.checkedReportFields = function() {
        return selectors.reportFields.filter(':checked');
    };

    utils.serializeFilters = function() {
        var filters = $('#active-filters div'),
                fieldFilters = {};

        $.each(filters, function() {
            var filter = $(this),
                    field = filter.find('.filter-field').val(),
                    type = filter.find('.filters').val(),
                    value = filter.find('.filter-value').val(),
                    toAry = function(type, value) {
                        if (value) { return [ type,value ] } else { return [type] }
                    },
                    isDuplicatedOrNotCombineAble = function(type) {
                        var result = true;
                        $.each(fieldFilters[field], function() {
                            if ( (this[0] == type) || ($.reporting.notCombineAbleFilters[this[0]].indexOf(type) != -1) ) {
                                result = false;
                            }
                        });
                        return result;
                    };
            if (field in fieldFilters) {
                if ( isDuplicatedOrNotCombineAble(type) )  {
                    fieldFilters[field].push( toAry(type,value) );
                }
            } else {
                fieldFilters[field] = [ toAry(type, value) ];
            }
        });


        $('#new_report').find('input[name*="report[filters]"]').remove();

        $.each(fieldFilters, function(field, filters) {
            var input = $('<input type="hidden" name="report[filters][' + field + ']" />');
            var value = '';

            $.each(filters, function(index) {
                value = value + this.join(':');
                if (filters[index + 1]) value = value + ';'
            });

            input.val( value );
            $('#new_report').append(input);

        });
    };

    // Collect report fields
    $.each( selectors.reportFields, function() {
        api.reportFields.push( $(this).attr('data-field-name') );
    });

    api.reportFieldsAmount = api.reportFields.length;

    $('form#new_report').bind('ajax:complete', function(event, xhr, status) {
        $(this).next().remove();
        if ( status = 'success' ) {
            $('#report-placeholder').html($.parseJSON(xhr.responseText).table);
            $('#report').removeClass('report-preview');
            $('input[name="report[page]"]').val("1");
            addPagination();
            $("tr:nth-child(odd)").addClass("alt");

        }
        $('#ajax-load-background').hide();
    }).bind('submit', function() {
        $.reporting.utils.serializeFilters();
        serializeFields();
    }).bind('ajax:beforeSend', function() {
        $(this).after( $.reporting.loader );
        $('#ajax-load-background').show();
    });

    $('strong.remove-filter').live('click', function() {
        $(this).parent('.filter').remove();
    });

    // TODO: REFACTOR STARTING FROM HERE PLEASE
    // Below crap was written in haste, I won't leave it like that, I promise

    var removeFilter = function() {
        /*YG: removed 'X' CSS works better here*/
        return $('<strong class="remove-filter"></strong>').clone();
    };

    var reportFilterTypeOnChange = function() {
        var reportFilterValue = $('<input type="text" class="filter-value" />');
        var $this = $(this),
                $filter = $this.parent('.filter');
        $filter.find('.filter-value').remove();
        $filter.find('.remove-filter').remove();
        if ( $.reporting.filtersRequiringInput.indexOf( $this.val() ) != -1 ) {
            $filter.append( reportFilterValue.clone() );
        }
        $filter.append( removeFilter );
    }, reportFieldFilterOnChange = function() {
        var filter = $(this).parent(),
                filterTypesSelection = $('#available-filters').
                        find('.' + $(this).find(':selected').attr('class') + '-filters').
                        clone();
        filter.find('.filters').remove();
        filter.find('.filter-value').remove();
        filter.find('.remove-filter').remove();
        filter.append( filterTypesSelection.bind('change', reportFilterTypeOnChange) ).append( removeFilter );
    };
    /*YG: replaced div with a*/
    $('a.add-new-filter').click(function() {
        var filter = $('<div class="filter"></div>');
        var reportFieldFilterSelection =  $('.filter-field-dummy').clone().
                removeClass('filter-field-dummy hidden').addClass('filter-field');
        var reportFilterTypeSelection = $('#available-filters').
                find('.' + reportFieldFilterSelection.find(':selected').attr('class') + '-filters').clone();


        reportFieldFilterSelection.bind('change', reportFieldFilterOnChange);
        reportFilterTypeSelection.bind('change', reportFilterTypeOnChange);

        filter.append(reportFieldFilterSelection).append(reportFilterTypeSelection).append(removeFilter);

        $('div#active-filters').append(filter);

    });

    $('a#download-csv').click(function(event) {
        event.preventDefault();
        var form = $('form#new_report').
                removeAttr('data-remote'), // Calm down, we'll set it back
                jqExpando = [];

        // Here goes some dirty, uhm, meaning "dark" magic
        $.each( form.data(), function(key,val) {
            if (/jQuery/.test(key)) {
                jqExpando = [key,val];
                delete form.data()[key];
                delete form.data()['remote'];
            }
        });

        form.submit();
        form.attr('data-remote', true);  // Man said - man did
        form.data( jqExpando[0], jqExpando[1] );
        return false;
    });

    selectors.selectedColumns = 'div#selected-columns';
    selectors.availableColumns = 'div#available-columns';

//    $('div.draggable').draggable({
//        revert:'invalid',
//        start: function() {   // We need to track where column has been dragged from initially
//            var $this = $(this);
//            $this.data('dragged-from', $this.parent().attr('id') );
//        }
//    });
//
//    $('div#available-columns').dropable({
//        accept: '.draggable'
//    })

//    $('div.droppable').droppable({
//        accept: '.draggable',
//        drop: function(event, ui) {
//
//            var $this = $(this),
//                    id = $this.attr('id'),
//                    column = ui.draggable.text().trim(),
//                    selectedColumnsAmount = $('div#selected-columns').children('div.draggable').length;
//
//            appendDraggable( $this, ui.draggable );
//
//            if ( id != ui.draggable.data('dragged-from') ) { // Thanks for a valid drop
//
//                if ( id == 'available-columns' ) { // Exclude column
//                    if ( selectedColumnsAmount > 1 ) {
//                        toggleColumn(ui.draggable);
//                    }
//                    else {
//                        appendDraggable( $(selectors.selectedColumns), ui.draggable ); // Revert back
//                    }
//                } else { // Include column
//                    toggleColumn(ui.draggable);
//                }
//
//            } else if ( ui.draggable.data('dragged-from') == 'selected-columns' ) {
//                appendColumn( reportColumn(ui.draggable) );
//            }
//        }
//    });

    $('div#selected-columns, div#available-columns').sortable({
        connectWith: '.connectedSortable',
        start: function(event, ui) {
            ui.item.data('dragged-from', ui.item.parent().attr('id') );
        }
//        },
//        update: function(event, ui) {
//            var $this = $(this),
//                id = $this.attr('id'),
//                column = ui.item.text().trim(),
//                sender = $('#' + ui.item.data('dragged-from'));
//
//            alert('yep');
//        }
    }).disableSelection();

    $('div#selected-columns').bind('sortupdate', function(event, ui) {
        var $this = $(this),
                column = ui.item.text().trim(),
            // selectedColumnsAmount = $('div#selected-columns').children('div.column-header').length,
                sender = $('#' + ui.item.data('dragged-from'));

        if ( sender.attr('id') == 'selected-columns' && ui.item.parent().attr('id') == 'available-columns' ) {
            hideColumn( reportColumn(ui.item) )
        } else {

            if ( reportColumn( ui.item ) ) {
                rebuildTable();
            } else {
                serializeFields();
                $('form#new_report').submit();
            }
//            var reportRows = $('#report tr').toArray(),
//                    columns = allIncludedReportColumns();
//
//            reportRows.shift(); reportRows.pop();
//
//            $.each( columns, function() {
//
//                if ( !this.header.is(':visible') ) {
//                    showColumn(this);
//                }
//
//                $('#report-header').append( this.header );
//                // alert( $(this.header).attr('abbr') );
//                var elements = this.elements.toArray();
//
//                $.each( reportRows, function() {
//                    $(this).append( elements.shift() );
//                });
//            });

        }
//        $('#report tr').html('');
//
//
//
//        var reportRows = $('#report tr').toArray();
//        reportRows.shift(); reportRows.pop();
//
//        $.each( columns, function() {
//
//            $('#report-header').append( $(this.header) );
//             // alert( $(this.header).attr('abbr') );
//            var elements = this.elements.toArray();
//
//            $.each( reportRows, function() {
//                $(this).append( $( elements.shift() ) );
//            });
//        });

//        $.each( columns, function() {
//
//            var elements = this.elements.toArray();
//            this.header.show();
//
//            $.each( elements, function(index) {
//                elements[index].show();
//            })
//        });

//        var reportRows = $('#report').find('tr').toArray(),
//                elements = column.elements.toArray();
//
//        reportRows.shift(); reportRows.pop(); // Remove header and footer rows
//
//        $('#report-header').append( column.header.show() ); // Append header
//
//        $.each(reportRows, function() { // append elements
//            $(this).
//                    append( $( elements.shift() ).show() );
//        });
    });


});

function rebuildTable() {

    var reportRows = $('#report tr').toArray(),
            columns = allIncludedReportColumns();

    reportRows.shift(); reportRows.pop();

    $.each( columns, function() {

        if ( !this.header.is(':visible') ) showColumn(this);

        $('#report-header').append( this.header );
        var elements = this.elements.toArray();

        $.each( reportRows, function() {
            $(this).append( elements.shift() );
        });
    });
}

function addPagination(){
    $(".paging a").each(function(i, val) {
        $(this).click(function(event){
            event.preventDefault();
            $('input[name="report[page]"]').val($(this).attr("id"));
            $('form.form_for').submit();
        });
    });

}

/* DRAG AND DROP FUNCTIONS */

function appendDraggable(element, draggable) {
    element.append( draggable.removeAttr('style') ); // Remove 'position', 'top' and 'left'
    draggable.css({
        position: 'relative'  // Retain the position and draggability (how do you like this word?)
    });
}

function reportColumn(col) {
    var table = $('#report'),
            columnNumber,
            columnName = col.text().trim(),
            columnHeader,
            columnElements = [];

    $.each( table.find('th'), function(index, element) {
        if ( $(element).attr('abbr') == columnName ) {
            columnNumber = index + 1;
            columnHeader = $(element);
        }
    });

    if ( columnHeader ) { // Column is there but is hidden
        columnElements = table.find('td:nth-child(' + columnNumber + ')');
        return { header: columnHeader, elements: columnElements };
    } else { // Report has been generated without this column
        return null;
    }

}

function allIncludedReportColumns() {
    var columns = [],
            table = $('#report');

//    var columnPosition = function(columnName) {
//        var result = 0;
//        $.each( table.find('th'), function(index, element) {
//            if ( $(element).attr('abbr') == columnName )
//                result = index + 1;
//        });
//        return result;
//    };

    $.each( $('#selected-columns div.column-header'), function() {
//        var $element = $(element),
//                column = {
//                    header: $element,
//                    elements: table.find('td:nth-child(' + columnPosition($element.attr('abbr')) + ')')
//                };
        columns.push( reportColumn( $(this) ) );
    });
    return columns;
}

function toggleColumn(col) {

    var column = reportColumn(col);

    synchronizeFields( col );

    if ( column ) {
        if ( column.header.is(':visible') ) {
            hideColumn(column);
        } else {
            if ( orderChanged() ) {
                appendColumn( column );
            } else {
                showColumn(column);
            }
        }
    } else {
        serializeFields();
        $('form#new_report').submit();
    }

}

function appendColumn(column) {
    var reportRows = $('#report').find('tr').toArray(),
            elements = column.elements.toArray();

    reportRows.shift(); reportRows.pop(); // Remove header and footer rows

    $('#report-header').append( column.header.show() ); // Append header

    $.each(reportRows, function() { // append elements
        $(this).
                append( $( elements.shift() ).show() );
    });
}

function showColumn(column) {
    column.header.show();
    column.elements.show();
}

function hideColumn(column) {
    column.header.hide();
    column.elements.hide();
}

function synchronizeFields( column ) {
    // Since you didn't want this column to be included in report we're removing it from ORDER BY selection. Blame yourself, I'm just saying
    var selectors = $.reporting.selectors,
            columnName = column.text().trim(),
            orderByOption = selectors.orderBy.find('option[value="' + columnName + '"]'),
            containerId = column.parent().attr('id'),
            columnToSelect = $('div#selected-columns').children().first().text().trim();

    if ( containerId == 'available-columns' ) { // Exclude column
        orderByOption.hide();
        if ( orderByOption.is(':selected')) selectors.orderBy.val( columnToSelect );
    } else { // Include column
        orderByOption.show();
    }

}

function selectedReportColumns() {
    var columns = [];

    $.each( $('div#selected-columns').children(), function() {
        columns.push( $(this).text().trim() );
    });

    return columns;
}

function serializeFields() {
    $('input#report_fields').val( selectedReportColumns().join(',') );
}

function orderChanged() {
    var reportColumns = selectedReportColumns(),
            serializedColumns = $('input#report_fields').val().split(','),
            serializedAndVisibleOrder = [],
            result = false;

    if ( reportColumns.length == serializedColumns.length ) {
        result = reportColumns.equals( serializedColumns );
    } else {
        serializedAndVisibleOrder = serializedColumns.slice(0, reportColumns.length);
        result = reportColumns.equals( serializedAndVisibleOrder );
    }

    return !result;
}
