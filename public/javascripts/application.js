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


    // Fields Selection
    selectors.reportFields.click(function(event) {
        var $this = $(this),
            checked = $this.prop('checked'),
            option = selectors.orderBy.find('option[value="' + $this.attr('data-field-name') + '"]'),
            optionValue = option.attr('value'),
            firstCheckedCheckbox = function() {
               return $.reporting.selectors.reportFieldsContainer.
                        find('input[type="checkbox"]').filter(':checked').first();
            };

        if ($.reporting.reportFields.indexOf(optionValue) == 0 && (option.is(':selected'))) {
             // The first option in drop-down has been enabled
            if (checked) {
                option.show();  alert('test');
            } else {  // The first option in drop-down has been disabled, find closest visible and set as selected

                selectors.orderBy.val(firstCheckedCheckbox().attr('data-field-name'));
                option.hide();
            }
        } else {
           if (checked) {
               option.show();
           } else {
               option.hide();
               selectors.orderBy.val(firstCheckedCheckbox().attr('data-field-name'));
           }
        }

        if ( utils.checkedReportFields().length == 0 ) {
            $this.prop('checked', true);
            option.attr('selected', true);
        }
    });


    $('form#new_report').bind('ajax:complete', function(event, xhr, status) {
        if ( status = 'success' ) {
            $('#report-placeholder').html($.parseJSON(xhr.responseText).table);
        }
    })

});