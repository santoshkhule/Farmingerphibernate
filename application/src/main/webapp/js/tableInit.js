/* Farming ERP — DataTables global initialisation */
$(document).ready(function () {
    $('table.tbl-data').each(function () {
        if (!$.fn.DataTable.isDataTable(this)) {
            $(this).DataTable({
                pageLength: 25,
                lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
                autoWidth: false,
                language: {
                    search:           '',
                    searchPlaceholder:'Search...',
                    lengthMenu:       'Show _MENU_ entries',
                    info:             '_START_ - _END_ of _TOTAL_',
                    infoEmpty:        '0 entries',
                    emptyTable:       'No records found',
                    paginate: { previous: '&#8249;', next: '&#8250;' }
                },
                dom: '<"dt-toolbar"lf>rt<"dt-footer"ip>'
            });
        }
    });
});
