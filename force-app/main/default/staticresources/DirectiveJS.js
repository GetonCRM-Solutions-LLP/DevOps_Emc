var MileagesofReimbursements = function (visible) {
    this.visible = visible;
  };
  
  MileagesofReimbursements.prototype.open = function(fileName,name,mileageList,emailOfEmployee) {
      this.visible = true;
      this.fileName = fileName;
      this.name = name;
      this.mileageList = mileageList;
      this.emailOfEmployee = emailOfEmployee;
  };

  MileagesofReimbursements.prototype.close = function() {
    this.visible = false;
  };
//Search Bar Directive

app.directive('searchBarDirective', function(){
    return{
        restrict: 'E',
        template: '<div id="example_filter" class="dataTables_filter pull-left d-block" ng-show="lengthformyteam > 10"><div class="input-group w-85"> <i id="filtericon" class="fa fa-search" ng-if="search.length===0"></i> <input class="form-control py-2 border-right-0 border" type="search" ng-model="search" placeholder="Search" aria-controls="example" id="example-search-input"  ng-keypress="keyPressed($event, search.length)" /></div></div>',
        link: function(scope){
            scope.search="";
            console.log(scope.lengthformyteam);
            scope.keyPressed = function (keyEvent, len) {
                    if (keyEvent.keyCode == 13 || (keyEvent.keyCode == 32 && !len)) {
                        keyEvent.preventDefault();
                    }
                    // return keyEvent.which !== 32;
                };
        }
    }
});

app.directive('searchbarUnapproveDirective', function(){
    return{
        restrict: 'E',
        template: '<div id="example_filter" class="dataTables_filter pull-right d-block" ng-show="searchbartrueforunapprove"><div class="input-group w-85" > <i id="filtericon" class="fa fa-search" ng-if="searchforunapprove.length===0"></i> <input class="form-control py-2 border-right-0 border" type="search" ng-model="searchforunapprove" placeholder="Search" aria-controls="example" id="example-search-input"  ng-keypress="keyPressed($event, searchforunapprove.length)"/></div></div>',
        link: function(scope){
            scope.searchforunapprove="";
            scope.keyPressed = function (keyEvent, len) {
                if (keyEvent.keyCode == 13 || (keyEvent.keyCode == 32 && !len)) {
                    keyEvent.preventDefault();
                }
                // return keyEvent.which !== 32;
            };
        }
    }
});




//Excel Export Directive
app.directive('excelExport', function () {
return {
    restrict: 'A',
    scope: {
        fileName: "@",
        data: "&exportData"
    },
    replace: true,
    template: '<button class="btn btn-primary float-right" ng-click="download()">Download <i class="fa fa-download"></i></button>',
    link: function (scope, element) {

        scope.download = function () {

            function datenum(v, date1904) {
                if (date1904) v += 1462;
                var epoch = Date.parse(v);
                return (epoch - new Date(Date.UTC(1899, 11, 30))) / (24 * 60 * 60 * 1000);
            };

            function getSheet(data, opts) {
                var ws = {};
                var range = { s: { c: 10000000, r: 10000000 }, e: { c: 0, r: 0 } };
                for (var R = 0; R != data.length; ++R) {
                    for (var C = 0; C != data[R].length; ++C) {
                        if (range.s.r > R) range.s.r = R;
                        if (range.s.c > C) range.s.c = C;
                        if (range.e.r < R) range.e.r = R;
                        if (range.e.c < C) range.e.c = C;
                        var cell = { v: data[R][C] };
                        if (cell.v == null) continue;
                        var cell_ref = XLSX.utils.encode_cell({ c: C, r: R });

                        if (typeof cell.v === 'number') cell.t = 'n';
                        else if (typeof cell.v === 'boolean') cell.t = 'b';
                        else if (cell.v instanceof Date) {
                            cell.t = 'n'; cell.z = XLSX.SSF._table[14];
                            cell.v = datenum(cell.v);
                        }
                        else cell.t = 's';

                        ws[cell_ref] = cell;
                    }
                }
                if (range.s.c < 10000000) ws['!ref'] = XLSX.utils.encode_range(range);
                return ws;
            };

            function Workbook() {
                if (!(this instanceof Workbook)) return new Workbook();
                this.SheetNames = [];
                this.Sheets = {};
            }

            var wb = new Workbook(), ws = getSheet(scope.data());

            /* add worksheet to workbook */
            wb.SheetNames.push(scope.fileName);
            wb.Sheets[scope.fileName] = ws;

            var wbout = XLSX.write(wb, { bookType: 'xlsx', bookSST: true, type: 'binary' });
            function s2ab(s) {
                var buf = new ArrayBuffer(s.length);
                var view = new Uint8Array(buf);
                for (var i = 0; i != s.length; ++i) view[i] = s.charCodeAt(i) & 0xFF;
                return buf;
            }
            saveAs(new Blob([s2ab(wbout)], { type: "application/octet-stream" }), scope.fileName + '.xlsx');
        };
    }
};
});

//Manager Dialog Directive
app.directive('managerDialogDirective', [function() {
    return {
        restrict: 'E',
        scope: {
            model: '=',
            data: "&exportData"
        },
        link: function(scope, element, attributes) {
            scope.$watch('model.visible', function(newValue) {
                var modalElement = element.find('.modal');
                modalElement.modal(newValue ? 'show' : 'hide');
                if(newValue == true) {
                    if(scope.model.managerList.length > 8)
                        scope.showmanagermodalsearchbar = true;
                    else
                        scope.showmanagermodalsearchbar = false;
                }
            });
            scope.showmanagermodalsearchbar = false;
            scope.search="";
            scope.sortKey1 = 'Name';
            scope.reverse1 = false;
            scope.pageSize = 8;
            scope.currentPage = 1;
            scope.sortBy1 = function(keyname1) {
                scope.reverse1 = (scope.sortKey1 === keyname1) ? !scope.reverse1 : false;
                scope.sortKey1 = keyname1;
            };

            element.on('shown.bs.modal', function() {
                scope.$apply(function() {
                    scope.model.visible = true;
                });
            });

            element.on('hidden.bs.modal', function() {
                scope.$apply(function() {
                    scope.model.visible = false;
                });
            });
        },
        template: '<div class="modal fade show in" tabindex="-1" role="dialog" aria-labelledby="driver-dashboard-monthrecord" id="driver-dashboard-monthrecord"><div class="modal-dialog modal-xl modal-dialog-centered"><div class="modal-content rounded-0"><button type="button" class="close popup-close-btn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button><div class="modal-body"><h4>Manager List</h4><div class="modal-divider"></div><div class="table-responsive"><div id="example_filter" class="dataTables_filter pull-right d-block" ng-show="showmanagermodalsearchbar"><div class="input-group w-85" ><i id="filtericon" class="fa fa-search" ng-if="search.length===0"></i><input class="form-control py-2 border-right-0 border" type="search" ng-model="search" ng-change="updatePagination()" placeholder="Search..." aria-controls="example" id="example-search-input" /></div></div><table id="driver-dashbord-month-model" class="table table-striped dt-responsive nowrap dataTable no-footer" cellspacing="0" width="100%"><thead><tr><th ng-click="sortBy1(\'Name\')">Manager Name<span ng-show="sortKey1 == \'Name\'" class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sortBy1(\'Email\')">Email<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}" ng-show="sortKey1 == \'Email\'"></span></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="manager in model.managerList | orderBy:sortKey1:reverse1|filter:search|itemsPerPage:pageSize" current-page="currentPage"><td><a href="/app/managerdashboardfromadmindriver?managerid={{manager.Id}}&accid={{manager.AccountId}}&id={{model.aid}}&showteam={{model.showteam}}&admindriver=true">{{ manager.Name }}</a></td><td><a href="mailto:{{ manager.Email}}" target="_blank">mailto:{{ manager.Email}}</a></td></tr></tbody></table><dir-pagination-controls max-size="5"  direction-links="true" boundary-links="true" auto-hide ="true" responsive="true" class="pull-right"></dir-pagination-controls></div></div><div class="modal-footer"><div excel-export="true" export-data="data()" file-name="{{model.filename}}"/></div></div></div></div></div>'
    };
}]);


//My Team Table Directive

app.directive('myteamTableDirective',[function(){
    return{
        restrict: 'E',
        link: function(scope){
           
             //Sorting For table of all Reimburesment
             scope.sortKey = 'Name';    //set the sortKey to the param passed   

             scope.sort = function (keyname) {

                scope.reverse = (scope.sortKey === keyname) ? !scope.reverse : false;
                scope.sortKey = keyname;
                if (keyname === 'threshold' || keyname === 'totalMileages' || keyname === 'approvedMileages' || keyname === 'rejectedMileages') {
                    scope.AllDriversLastMonthReimbursements.sort(function (a, b) {
                        var nameA = parseInt(a[keyname]),
                            nameB = parseInt(b[keyname]);
                        if (scope.reverse) {
                            if (nameA < nameB) //sort string ascending
                                return -1
                            if (nameA > nameB)
                                return 1
                            return 0
                        } else {
                            if (nameA < nameB) //sort string ascending
                                return 1
                            if (nameA > nameB)
                                return -1
                            return 0 //default return value (no sorting)
                        }
                    })
                }
                if (keyname === 'name') {
                    scope.AllDriversLastMonthReimbursements.sort(function (a, b) {
                        var nameA = a[keyname].toLowerCase(),
                            nameB = b[keyname].toLowerCase()
                        if (scope.reverse) {
                            if (nameA < nameB) //sort string ascending
                                return -1
                            if (nameA > nameB)
                                return 1
                            return 0 //default return value (no sorting)
                        } else {
                            if (nameA < nameB) //sort string ascending
                                return 1
                            if (nameA > nameB)
                                return -1
                            return 0 //default return value (no sorting)
                        }
                    })
                }
                scope.isPagination = false;
            }
        },
        template: '<table id="admindriver-dashboard" class="table table-striped dt-responsive nowrap dataTable textalign-c" cellspacing="0" width="100%"><thead><tr><th id="name" ng-click="sort(\'name\')">Name <span class="sort-icon pull-right" ng-show="sortKey==\'name\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><!-- <th ng-click="sort(\'threshold\')">Approval <br/>Threshold <span class="sort-icon pull-right" ng-show="sortKey==\'threshold\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"> </span></th>--><th ng-click="sort(\'totalMileages\')">Submitted <br/>Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'totalMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'rejectedMileages\')">Flagged <br/>Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'rejectedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'approvedMileages\')">Approved <br/>Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'approvedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'approvedDate\')" class="approvedDateth"> <span class="sort-icon pull-right" ng-show="sortKey==\'approvedDate\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span><div ng-if="displayApprovebtn" class="btn btn-primary-approve"> <span class="appspan">Approve</span> <input type="checkbox" class="approvechk" ng-model="checkboxObj.IsAllCheckedForApprove" ng-click="myTeamCheckUncheckAll(checkboxObj.IsAllCheckedForApprove)" /></div></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="LastMonthReimbursement in AllDriversLastMonthReimbursements|filter:search|itemsPerPage:pageSize" current-page="currentPage" ng-model="LastMonthReimbursement"><td ng-model="LastMonthReimbursement.name"> <a href="/app/admindriverdashboardfromadminmanager?accid={{accid}}&id={{LastMonthReimbursement.contactid}}&adminid={{aid}}&showteam={{showteam}}">{{LastMonthReimbursement.name}} </a></td><!--<td ng-model="LastMonthReimbursement.threshold"> <input type="text" ng-change="showbtn(LastMonthReimbursement.contactid,LastMonthReimbursement.threshold)" ng-model="LastMonthReimbursement.threshold" id="numberinput" class="numinputedit form-control rounded-0 col-md-6" value="{{LastMonthReimbursement.threshold | number:2}}" /></td>--><td ng-model="LastMonthReimbursement.totalMileages"> {{LastMonthReimbursement.totalMileages | number:2}}</td><td ng-model="LastMonthReimbursement.totalMileages"> {{LastMonthReimbursement.rejectedMileages | number:2}}</td><td ng-model="LastMonthReimbursement.approvedMileages"> {{LastMonthReimbursement.approvedMileages | number:2}}</td><td><div class="statusapprove" ng-model="LastMonthReimbursement.status" ng-if="LastMonthReimbursement.status!=\'Pending\' && LastMonthReimbursement.totalMileages > \'0.00\'"> {{LastMonthReimbursement.status}} on {{LastMonthReimbursement.approvedDate}}</div><div ng-if="LastMonthReimbursement.status ==\'Pending\' && LastMonthReimbursement.totalMileages > \'0.00\'"> <input type="checkbox" ng-model="LastMonthReimbursement.isSelected" ng-click="CheckUncheckHeader(LastMonthReimbursement.status)" class="myteamcheck" /></div></td></tr><tr ng-if="lengthformyteam == 0 || (AllDriversLastMonthReimbursements | filter:search).length == 0""><td colspan="6" class="table-nodata">No Mileage Available</td></tr></tbody></table>  <div ng-if="lengthformyteam > 30"><dir-pagination-controls max-size="1" direction-links="true" boundary-links="true" responsive="true" auto-hide="false" class="pull-right"></dir-pagination-controls></div>'
    };
}]);


app.directive('unapprovemileageTableDirective',[function(){
     return{
         restrict: 'E',
         link: function(scope){
             //Sorting For table of all Un Approved Reimburesment
             scope.sortKey1 = 'Name';   //set the sortKey to the param passed   
             scope.reverse1 = false;
             scope.sort1 = function(keyname){
                scope.sortKey1 = keyname;   //set the sortKey to the param passed
                scope.reverse1 = !scope.reverse1; //if true make it false and vice versa
                if (keyname === 'threshold' || keyname === 'totalMileages' || keyname === 'approvedMileages') {
                    scope.AllDriversLastMonthUnapprovedReimbursementsClone.sort(function (a, b) {
                                        var numA = parseFloat(a[keyname]),
                                            numB = parseFloat(b[keyname]);
                                        if (scope.reverse1) {
                                            if (numA < numB) //sort string ascending
                                                return -1
                                            if (numA > numB)
                                                return 1
                                            return 0
                                        } else {
                                            if (numA < numB) //sort string ascending
                                                return 1
                                            if (numA > numB)
                                                return -1
                                            return 0 //default return value (no sorting)
                                        }
                                    })
                                }
                                if (keyname === 'name') {
                                    scope.AllDriversLastMonthUnapprovedReimbursementsClone.sort(function (a, b) {
                                        var nameA = a[keyname].toLowerCase(),
                                            nameB = b[keyname].toLowerCase()
                                        if (scope.reverse1) {
                                            if (nameA < nameB) //sort string ascending
                                                return -1
                                            if (nameA > nameB)
                                                return 1
                                            return 0 //default return value (no sorting)
                                        } else {
                                            if (nameA < nameB) //sort string ascending
                                                return 1
                                            if (nameA > nameB)
                                                return -1
                                            return 0 //default return value (no sorting)
                                        }
                                    })
                                }
            }
         },
         template:'<table id="admindriver-mileage-dashboard" class="table table-striped dt-responsive nowrap dataTable textalign-c" cellspacing="0" width="100%"><thead><tr><th id="nameforunapprove" ng-click="sort1(\'name\')">Name <span class="sort-icon pull-right" ng-show="sortKey1==\'name\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><!--<th ng-click="sort1(\'threshold\')">Approval<br/> Threshold <span class="sort-icon pull-right" ng-show="sortKey1==\'threshold\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"> </span></th>--><th ng-click="sort1(\'totalMileages\')">Unapproved<br/> Mileage <span class="sort-icon pull-right" ng-show="sortKey1==\'totalMileages\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sort1(\'approvedMileages\')">Approved<br/> Mileage <span class="sort-icon pull-right" ng-show="sortKey1==\'approvedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sort1(\'name\')">Approving<br/>Manager <span class="sort-icon pull-right" ng-show="sortKey1== \'name\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th class="emailth"> <button class="btn btn-secondary pull-right w-68 plt-0" ng-if="displayEmailReminder"><span class="emailspan">Email</span><br/><span>Reminder</span>&nbsp;<input ng-show="checkAllShowForUnApprove" class="emailchk" type="checkbox" ng-model="checkboxObj.IsAllEmailCheckedForUnapprove" ng-click="unApprovedEmailCheckUncheckAll(checkboxObj.IsAllEmailCheckedForUnapprove)" /></button></th><th class="approvedDateth"> <button class="btn btn-primary-approve" ng-if="displayApprovebtn"><span class="appspan">Approve</span><input ng-show="checkAllShowForUnApprove" class="approvechk" type="checkbox" ng-model="checkboxObj.IsAllCheckedForUnapprove" ng-click="unApprovedCheckUncheckAll(checkboxObj.IsAllCheckedForUnapprove)" /></button></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="UnapprovedReimburesement in AllDriversLastMonthUnapprovedReimbursementsClone |filter:searchforunapprove|itemsPerPage:pageSize" current-page="currentPage" ng-model="UnapprovedReimburesement"><td ng-model="UnapprovedReimburesement.name" > <a ng-click="openmodalForunapprovedata(UnapprovedReimburesement.name,UnapprovedReimburesement.contactid,UnapprovedReimburesement,UnapprovedReimburesement.managerName)">{{UnapprovedReimburesement.name}} </a></td><!--<td ng-model="UnapprovedReimburesement.threshold" > {{UnapprovedReimburesement.threshold | number:2 }}</td>--><td ng-model="UnapprovedReimburesement.totalMileages" > {{UnapprovedReimburesement.totalMileages | number:2 }}</td><td ng-model="UnapprovedReimburesement.approvedMileages" > {{UnapprovedReimburesement.approvedMileages | number:2 }}</td><td ng-model="UnapprovedReimburesement.name" > <a ng-click="openmodalForunapprovedata(UnapprovedReimburesement.name,UnapprovedReimburesement.contactid,UnapprovedReimburesement.mileagesList,UnapprovedReimburesement.managerName)">{{UnapprovedReimburesement.managerName}} </a></td><td ng-model="UnapprovedReimburesement.status" ><div ng-model="UnapprovedReimburesement.status" ng-if="UnapprovedReimburesement.status==\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\'"></div><div> <input type="checkbox" ng-model="UnapprovedReimburesement.isSelectedEmailReminder" ng-change="CheckUncheckHeaderUnapproveForEmail()" class="upapprovechk mr-6" /></div></td><td ng-model="UnapprovedReimburesement.status" ><div class="statusapprove" ng-model="UnapprovedReimburesement.status" ng-if="UnapprovedReimburesement.status==\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\'"> {{UnapprovedReimburesement.status}} on {{UnapprovedReimburesement.approvedDate}}</div><div ng-if="UnapprovedReimburesement.status !=\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\'"> <input type="checkbox" ng-model="UnapprovedReimburesement.isSelected" ng-change="CheckUncheckHeaderUnapprove()" class="upapprovecheck" /></div></td></tr><tr ng-if="lengthforunapprovebtndisable == 0 ||  (AllDriversLastMonthUnapprovedReimbursementsClone | filter:searchforunapprove).length == 0 "><td colspan="5" class="table-nodata">No Mileage Available</td></tr></tbody></table><div ng-if="lengthforunapprovebtndisable > 30"><dir-pagination-controls max-size="5" direction-links="true" boundary-links="true" auto-hide="false" responsive="true" class="pull-right"></dir-pagination-controls></div>'
     }
}]);







app.directive('managerteamTableDirective',[function(){
    return{
        restrict: 'E',
        link: function(scope){
             //Sorting For table of all Reimburesment
             scope.sortKey = 'Name';    //set the sortKey to the param passed   

             scope.sort = function (keyname) {
                
                scope.reverse = (scope.sortKey === keyname) ? !scope.reverse : false;
                scope.sortKey = keyname;
                if (keyname === 'threshold'|| keyname === 'totalMileages' || keyname === 'rejectedMileages' || keyname ==='approvedMileages') {
                    scope.AllDriversLastMonthReimbursements.sort(function (a, b) {
                        
                                        var numA = parseInt(a[keyname]),
                                            numB = parseInt(b[keyname]);
                                        if (scope.reverse) {
                                            if (numA < numB) //sort string ascending
                                                return -1
                                            if (numA > numB)
                                                return 1
                                            return 0
                                        } else {
                                            if (numA < numB) //sort string ascending
                                                return 1
                                            if (numA > numB)
                                                return -1
                                            return 0 //default return value (no sorting)
                                        }
                    })
                }
                if (keyname === 'approvedDate') {
                    scope.AllDriversLastMonthReimbursements.sort(function (a, b) {
                        
                        var dateA = (a[keyname]=='') ? '' : new Date(a[keyname].toLowerCase()),
                            dateB = (b[keyname]=='') ? '' : new Date(b[keyname].toLowerCase())
                        if (scope.reverse) {
                            if (dateA < dateB) //sort string ascending
                                return -1
                            if (dateA > dateB)
                                return 1
                            return 0 //default return value (no sorting)
                        } else {
                            if (dateA < dateB) //sort string ascending
                                return 1
                            if (dateA > dateB)
                                return -1
                            return 0 //default return value (no sorting)
                        }
                    })
                }
                if (keyname === 'name') {
                    scope.AllDriversLastMonthReimbursements.sort(function (a, b) {
                        var nameA = a[keyname].toLowerCase(),
                            nameB = b[keyname].toLowerCase()
                        if (scope.reverse) {
                            if (nameA < nameB) //sort string ascending
                                return -1
                            if (nameA > nameB)
                                return 1
                            return 0 //default return value (no sorting)
                        } else {
                            if (nameA < nameB) //sort string ascending
                                return 1
                            if (nameA > nameB)
                                return -1
                            return 0 //default return value (no sorting)
                        }
                    })
                }
                scope.isPagination = false;
            }

              //On click of Approve's button checkbox for approve tab
            //   scope.myTeamCheckUncheckAll = function (myTeamCheckUncheckAll) {
            //     scope.checkboxObj.IsAllCheckedForApprove = myTeamCheckUncheckAll

            //     if (scope.checkboxObj.IsAllCheckedForApprove == true)
            //         scope.displayTeamRecordBtn = true;
            //     else
            //         scope.displayTeamRecordBtn = false;

            //     angular.forEach(scope.AllDriversLastMonthReimbursements, function (LastMonthReimbursement) {
            //         LastMonthReimbursement.isSelected = scope.checkboxObj.IsAllCheckedForApprove;
            //     });
            //     angular.forEach(scope.AllDriversLastMonthReimbursements, function (item) {
            //         if (item.isSelected && item.status != 'Approved') {
            //             scope.myTeamReimbusement.push(item.id);

            //         }

            //     });
            //     scope.myTeamReimbusement = removeDumplicateValue(scope.myTeamReimbusement);
            // }
        },
        template: '<table id="manager-dashbord-team-record" class="table table-striped dt-responsive nowrap dataTable" cellspacing="0" width="100%"><thead><tr><th ng-click="sort(\'name\')">Name <span class="sort-icon pull-right" ng-show="sortKey==\'name\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><!--<th ng-click="sort(\'threshold\')">Approval Threshold <span class="sort-icon pull-right" ng-show="sortKey==\'threshold\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"> </span></th>--><th ng-click="sort(\'totalMileages\')">Submitted Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'totalMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'rejectedMileages\')">Flagged Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'rejectedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'approvedMileages\')">Approved Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'approvedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'approvedDate\')" class="approveth"><button class="btn btn-primary btn-primary-approve">Approve <input ng-show="checkAllShowForMyTeam" type="checkbox" ng-model="checkboxObj.IsAllCheckedForApprove" ng-click="myTeamCheckUncheckAll(checkboxObj.IsAllCheckedForApprove)" /> </button></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="LastMonthReimbursement in AllDriversLastMonthReimbursements|filter:search|itemsPerPage:pageSize" current-page="currentPage" ng-model="LastMonthReimbursement"><td ng-model="LastMonthReimbursement.name" ><a ng-if="!endProcess"  href="/app/admindrivermanagerdriver?accid={{accid}}&manid={{managerid}}&adminid={{adminid}}&id={{LastMonthReimbursement.contactid}}&showteam={{showteam}}&admindriver=true">{{LastMonthReimbursement.name}}</a><a ng-if="endProcess || LastMonthReimbursement.reimbursementApproval" ng-click="infoMessage()">{{LastMonthReimbursement.name}}</a></td><!--<td ng-model="LastMonthReimbursement.threshold" > {{LastMonthReimbursement.threshold}}</td>--><td ng-model="LastMonthReimbursement.totalMileages" > {{LastMonthReimbursement.totalMileages}}</td><td ng-model="LastMonthReimbursement.totalMileages" > {{LastMonthReimbursement.rejectedMileages}}</td><td ng-model="LastMonthReimbursement.approvedMileages" > {{LastMonthReimbursement.approvedMileages}}</td><td><div class="statusapprove" ng-model="LastMonthReimbursement.status" ng-if="LastMonthReimbursement.status==\'Approved\' && LastMonthReimbursement.totalMileages > \'0.00\'"> Approved on {{LastMonthReimbursement.approvedDate}}</div><div ng-if="LastMonthReimbursement.status !=\'Approved\' && LastMonthReimbursement.totalMileages > \'0.00\' && !LastMonthReimbursement.reimbursementApproval"> <input type="checkbox" ng-model="LastMonthReimbursement.isSelected" ng-change="CheckUncheckHeader()" class="myteamcheck mr-4" /></div><div class="statusapprove"  ng-if="LastMonthReimbursement.reimbursementApproval">Approval Processing</div></td></tr><tr ng-if="lengthformyteam == 0 || (AllDriversLastMonthReimbursements | filter:search).length == 0"><td colspan="6" class="table-nodata">No Mileage Available</td></tr></tbody></table>'
    };
}]);


app.directive('managerUnapprovemileageTableDirective',[function(){
    return{
        restrict: 'E',
        link: function(scope){
            //Sorting For table of all Un Approved Reimburesment
            scope.sortKey1 = 'Name';   //set the sortKey to the param passed   
            scope.reverse1 = false;
            scope.sort1 = function(keyname){
                
               scope.sortKey1 = keyname;   //set the sortKey to the param passed
               scope.reverse1 = !scope.reverse1; //if true make it false and vice versa
               if (keyname === 'threshold' || keyname === 'totalMileages' || keyname === 'approvedMileages') {
                   scope.AllDriversLastMonthUnapprovedReimbursementsclone.sort(function (a, b) {
                       
                                       var numA = parseInt(a[keyname]),
                                           numB = parseInt(b[keyname]);
                                       if (scope.reverse1) {
                                           if (numA < numB) //sort string ascending
                                               return -1
                                           if (numA > numB)
                                               return 1
                                           return 0
                                       } else {
                                           if (numA < numB) //sort string ascending
                                               return 1
                                           if (numA > numB)
                                               return -1
                                           return 0 //default return value (no sorting)
                                       }
                                   })
                               }
                               if (keyname === 'name') {
                                   scope.AllDriversLastMonthUnapprovedReimbursementsclone.sort(function (a, b) {
                                       
                                       var nameA = a[keyname].toLowerCase(),
                                           nameB = b[keyname].toLowerCase()
                                       if (scope.reverse1) {
                                           if (nameA < nameB) //sort string ascending
                                               return -1
                                           if (nameA > nameB)
                                               return 1
                                           return 0 //default return value (no sorting)
                                       } else {
                                           if (nameA < nameB) //sort string ascending
                                               return 1
                                           if (nameA > nameB)
                                               return -1
                                           return 0 //default return value (no sorting)
                                       }
                                   })
                               }
           }
        },
        template:'<table id="manager-dashbord-unapproved-record" class="table table-striped dt-responsive nowrap dataTable" cellspacing="0" width="100%"><thead><tr><th ng-click="sort1(\'name\')">Name <span class="sort-icon pull-right" ng-show="sortKey1==\'name\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><!--<th ng-click="sort1(\'threshold\')">Approval Threshold <span class="sort-icon pull-right" ng-show="sortKey1==\'threshold\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"> </span></th>--><th ng-click="sort1(\'totalMileages\')">Unapproved Mileage <span class="sort-icon pull-right" ng-show="sortKey1==\'totalMileages\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sort1(\'approvedMileages\')">Approved Mileage <span class="sort-icon pull-right" ng-show="sortKey1==\'approvedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th class="approveth"> <button class="btn btn-primary btn-primary-approve">Approve <input ng-show="checkAllShowForUnApprove" type="checkbox" ng-model="checkboxObj.IsAllCheckedForUnapprove" ng-click="unApprovedCheckUncheckAll(checkboxObj.IsAllCheckedForUnapprove)" /></button></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="UnapprovedReimburesement in AllDriversLastMonthUnapprovedReimbursementsclone|filter:search1|itemsPerPage:pageSize" current-page="currentPage" ng-model="UnapprovedReimburesement"><td ng-model="UnapprovedReimburesement.name" > <a ng-if="!endProcess" ng-click="openmodalForunapprovedata(UnapprovedReimburesement.name,UnapprovedReimburesement.contactid,UnapprovedReimburesement)">{{UnapprovedReimburesement.name}} </a> <a ng-if="endProcess || UnapprovedReimburesement.reimbursementApproval" ng-click="infoMessage()">{{UnapprovedReimburesement.name}} </a></td><!--<td ng-model="UnapprovedReimburesement.threshold" > {{UnapprovedReimburesement.threshold}}</td>--><td ng-model="UnapprovedReimburesement.totalMileages" > {{UnapprovedReimburesement.totalMileages}}</td><td ng-model="UnapprovedReimburesement.approvedMileages" > {{UnapprovedReimburesement.approvedMileages}}</td><td ng-model="UnapprovedReimburesement.status" ><div class="statusapprove" ng-model="UnapprovedReimburesement.status" ng-if="UnapprovedReimburesement.status==\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\'"> Approved on {{UnapprovedReimburesement.approvedDate}}</div><div ng-if="UnapprovedReimburesement.status !=\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\' && !UnapprovedReimburesement.reimbursementApproval"> <input type="checkbox" ng-model="UnapprovedReimburesement.isSelected" ng-change="CheckUncheckHeaderForUnapprove()" class="upapprovecheck mr-4" /></div> <div class="statusapprove"  ng-if="UnapprovedReimburesement.reimbursementApproval">Approval Processing</div></td></tr><tr ng-if="lengthforUnapprove == 0 || (AllDriversLastMonthUnapprovedReimbursementsclone | filter:searchforunapprove).length == 0"><td colspan="5" class="table-nodata">No Mileage Available</td></tr></tbody></table>'
    }
}]);





