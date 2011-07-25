// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

    var api = $.reporting = {
        version: 0,
        reportTypes: [],
        reportFields: [],
        reportFieldsAmount: 0,
        loader: ("<img class='loader' src='/images/loader.gif' />"),
        utils: {},
        selectors: {},
        filtersRequiringInput: ['equals', 'starts_with', 'ends_with', 'contains', 'less_than', 'more_than']
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
    utils.filter = function(type) {
        var filterFieldSelection = $('.filter-for-field').clone().
                removeClass('filter-field-dummy hidden').addClass('filter-field');
        var filterTypeSelection = $('#available-filters').find('.' + type);
        var filterValue = $('<input type="text" class="filter-value" />');
        var filter = $('<div class="filter"></div>').
                append(filterFieldSelection).
                append(filterTypeSelection).
                append(filterValue);

    };

    // Collect report fields
    $.each( selectors.reportFields, function() {
        api.reportFields.push( $(this).attr('data-field-name') );
    });

    api.reportFieldsAmount = api.reportFields.length;


    // ORDER BY Fields Selection
    selectors.reportFields.click(function() {
        // If user unchecks one of the fields - hide the corresponding ORDER BY and FILTER FOR options
        // If the corresponding option is selected - select another for for user
        // When user checks the checkbox - show the option back
        var $this = $(this),
                checked = $this.prop('checked'),
                fieldName = $this.attr('data-field-name'),
                orderByOption = selectors.orderBy.find('option[value="' + fieldName + '"]'),
                filterForOption = selectors.filtersForFields.find('option[value="' + fieldName + '"]'),
                options = [orderByOption, filterForOption],
                synchronizeFields = function() {
                    // User doesn't want the current 'ORDER BY' or 'FILTER FOR' (or both) field to be included into report.
                    // Select closest field for him and hide the current option
                    var field = $.reporting.selectors.reportFieldsContainer.
                            find('input[type="checkbox"]').filter(':checked').first().attr('data-field-name');
                    if (orderByOption.is(':selected')) selectors.orderBy.val(field);
                    if (filterForOption.is(':selected')) selectors.filtersForFields.val(field);
                };

        if ((orderByOption.is(':selected') || filterForOption.is(':selected'))  && !checked) {
            synchronizeFields();
            $.each(options, function() {this.hide()});
        } else {
            checked? $.each(options, function() {this.show()}) :
                    $.each(options, function() {this.hide()});
        }

        if ( utils.checkedReportFields().length == 0 ) {
            $this.prop('checked', true);
            $.each(options, function() {this.show().attr('selected', true)});
        }
    });


    $('form#new_report').bind('ajax:complete', function(event, xhr, status) {
        if ( status = 'success' ) {
            $('#report-placeholder').html($.parseJSON(xhr.responseText).table);
        }
    }).bind('ajax:beforeSend', function() {
        // Quick, add the serialized filters before form got serialized and sent
    });

    $('strong.remove-filter').live('click', function() {
        $(this).parent('.filter').remove();
    });

     // TODO: REFACTOR STARTING FROM HERE PLEASE
    // Below crap was written in haste, I won't leave it like that, I promise

    var removeFilter = function() {
        return $('<strong class="remove-filter">X</strong>').clone();
    };

    var blah2 = function() {
        var reportFilterValue = $('<input type="text" class="filter-value" />');
        var $this = $(this),
                $filter = $this.parent('.filter');
        $filter.find('.filter-value').remove();
        $filter.find('.remove-filter').remove();
        if ( $.reporting.filtersRequiringInput.indexOf( $this.val() ) != -1 ) {
            $filter.append( reportFilterValue.clone() );
        }
        $filter.append( removeFilter );
    };

    var blah = function() {
        var filter = $(this).parent(),
                filterTypesSelection = $('#available-filters').
                        find('.' + $(this).find(':selected').attr('class') + '-filters').
                        clone();
        filter.find('.filters').remove();
        filter.find('.filter-value').remove();
        filter.find('.remove-filter').remove();
        filter.append( filterTypesSelection.bind('change', blah2) ).append( removeFilter );
    };

    $('div.add-new-filter').click(function() {
        var filter = $('<div class="filter"></div>');
        var reportFieldFilterSelection =  $('.filter-field-dummy').clone().
                removeClass('filter-field-dummy hidden').addClass('filter-field');
        var reportFilterTypeSelection = $('#available-filters').
                find('.' + reportFieldFilterSelection.find(':selected').attr('class') + '-filters').clone();


        reportFieldFilterSelection.bind('change', blah);
        reportFilterTypeSelection.bind('change', blah2);

        filter.append(reportFieldFilterSelection).append(reportFilterTypeSelection).append(removeFilter);

        $('div#active-filters').append(filter);

    });

});