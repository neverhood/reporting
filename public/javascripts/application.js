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

    utils.checkedReportFields = function() {
        return selectors.reportFields.filter(':checked');
    };

    // Collect report fields
    $.each( selectors.reportFields, function() {
        api.reportFields.push( $(this).attr('data-field-name') );
    });

    api.reportFieldsAmount = api.reportFields.length;

    selectors.reportFields.click(function() {
        var $this = $(this);

        if ( utils.checkedReportFields().length == 0 ) {
            $this.prop('checked', true);
        }
    });




});