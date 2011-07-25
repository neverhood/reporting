// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

    var api = $.reporting = {
        version: 0,
        reportTypes: [],
        reportFields: [],
        reportFieldsAmount: 0,
        reportFieldTypes: {},
        loader: ("<img class='loader' src='/images/loader.gif' />"),
        utils: {},
        selectors: {}
    };

    var selectors = api.selectors,
            utils = api.utils;

    selectors.reportFieldsContainer = $('div#report-fields');
    selectors.reportFields = $(selectors.reportFieldsContainer).find('input[type="checkbox"]');
    selectors.orderBy = $('select#report_order_by');
    selectors.filtersForFields = $('select#report_filters_field');

    utils.checkedReportFields = function() {
        return selectors.reportFields.filter(':checked');
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
                    var field = $.reporting.selectors.reportFieldsContainer.
                            find('input[type="checkbox"]').filter(':checked').first().attr('data-field-name');
                    if (orderByOption.is(':selected')) selectors.orderBy.val(field);
                    if (filterForOption.is(':selected')) selectors.filtersForFields.val(field);
                };

        if ((orderByOption.is(':selected') || filterForOption.is(':selected'))  && !checked) {
            // User doesn't want the current 'ORDER BY' field to be included into report.
            // Select closest field for him and hide the current option
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
    })

});