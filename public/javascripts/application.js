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
        var $this = $(this),
                checked = $this.prop('checked'),
                option = selectors.orderBy.find('option[value="' + $this.attr('data-field-name') + '"]'),
                firstCheckedCheckbox = function() {
                    return $.reporting.selectors.reportFieldsContainer.
                            find('input[type="checkbox"]').filter(':checked').first();
                };

        if (option.is(':selected') && !checked) {
            // User doesn't want the current 'ORDER BY' field to be included into report.
            // Select closest field for him and hide the current option
            selectors.orderBy.val(firstCheckedCheckbox().attr('data-field-name'));
            option.hide();

        } else {
            checked? option.show() : option.hide();
        }

        if ( utils.checkedReportFields().length == 0 ) {
            $this.prop('checked', true);
            option.show().attr('selected', true);
        }
    });


    $('form#new_report').bind('ajax:complete', function(event, xhr, status) {
        if ( status = 'success' ) {
            $('#report-placeholder').html($.parseJSON(xhr.responseText).table);
        }
    })

});