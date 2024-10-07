var app = angular.module('admindriverdashboardModule', ['ui.bootstrap','angularUtils.directives.dirPagination','chart.js']);

//Search Bar Directive

app.directive('searchBarDirective', function(){
    return{
        restrict: 'E',
        template: '<div id="example_filter" class="dataTables_filter pull-left d-block" ng-show="searchbartrueformyteam"><div class="input-group w-85"> <i id="filtericon" class="fa fa-search" ng-if="search.length===0"></i> <input class="form-control py-2 border-right-0 border" type="search" ng-model="search" placeholder="Search" aria-controls="example" id="example-search-input" /></div></div>',
        link: function(scope){
            scope.search="";
        }
    }
});

app.directive('searchbarUnapproveDirective', function(){
    return{
        restrict: 'E',
        template: '<div id="example_filter" class="dataTables_filter pull-right d-block" ng-show="searchbartrueforunapprove"><div class="input-group w-85" > <i id="filtericon" class="fa fa-search" ng-if="searchforunapprove.length===0"></i> <input class="form-control py-2 border-right-0 border" type="search" ng-model="searchforunapprove" placeholder="Search" aria-controls="example" id="example-search-input" /></div></div>',
        link: function(scope){
            scope.searchforunapprove="";
        }
    }
});

//Reimbursments Dialog Directive

app.directive('reimbursementsDialogDirective', ['$filter',
function ($filter) {
    return {
        restrict: 'E',
        scope: {
            model: '=',
            data: "&exportData",
            someCtrlFn: '&callbackFn',
            modalformsg: '&modalOpen'
        },
        link: function (scope, element, attributes) {
            scope.$watch('model.visible', function (newValue) {
                var modalElement = element.find('.modal');
                modalElement.modal(newValue ? 'show' : 'hide');
                if (newValue == true) {
                    //scope.init()
                    scope.callfn('');
                }
                else {
                    scope.IsAllChecked = false;
                    scope.IsAllCheckedFlag = false;
                    scope.checkAllShowApprove = false;
                    scope.checkAllShowFlag = false;
                }
                angular.forEach(scope.model.mileageList, function (item) {
                    if (item.isSelected || item.isChecked) {
                        scope.selectedmonth = scope.model.clickedMonth;
                        scope.selectedyear = scope.model.clickedYear;
                        scope.selecteddid = item.driverid;
                    }
                });
            });

            scope.totalMileage = 0;
            scope.totalVariableAmount = 0;
            scope.showmanagermodalsearchbar = false;
            scope.selecteddid = '';
            scope.displayBtn = false;
            scope.IsAllChecked = false;
            scope.IsAllCheckedFlag = false;
            scope.checkAllShowApprove = false;
            scope.checkAllShowFlag = false;
            scope.selectedmileageidlist = [];
            scope.selectedrejectedmileageidlist = [];
            scope.showData = [];
            scope.total = 0;
            scope.totalvariablerate = 0;
            scope.currentPage = 1;
            scope.lastIndex = 0;
            scope.totalRecords;
            scope.reverse = false;
            scope.maxPage = 0;
            scope.search = "";
            scope.itemPerPage = 8;
            scope.searchedArray = [];
            scope.init = function () {
                scope.showData = [];
                scope.total = 0;
                scope.totalvariablerate = 0;
                scope.maxPage = 0;
                scope.totalRecords = scope.model.mileageList.length;
                scope.model.mileageList
                scope.maxPage = Math.ceil(scope.totalRecords / scope.itemPerPage)
                scope.totalRecords
                let tl = 0;
                let tv = 0;
                for (var i = 0; i < scope.itemPerPage; i++) {
                    scope.currentPage = 1;
                    if (scope.model.mileageList[i]) {
                        tl = tl + parseFloat(scope.model.mileageList[i].mileage);
                        tv = tv + parseFloat(scope.model.mileageList[i].variableamount);
                        scope.showData.push(scope.model.mileageList[i])
                    }
                    scope.lastIndex = i + 1;
                }
                scope.total = tl.toFixed(2);
                scope.totalvariablerate = tv.toFixed(2);
            }

            scope.next = function () {
                scope.showData = [];
                scope.total = 0;
                scope.totalvariablerate = 0;
                var lstInd = scope.lastIndex;
                let tl = 0;
                let tv = 0;

                for (var i = scope.lastIndex; i < lstInd + scope.itemPerPage; i++) {
                    let isSearch = scope.searchedArray.length > 0 ? true : false
                    if (isSearch) {
                        if (scope.searchedArray[i]) {
                            /*scope.total = scope.total + parseFloat(scope.model.mileageList[i].mileage);
                            scope.totalvariablerate = scope.totalvariablerate + parseFloat(scope.model.mileageList[i].variableamount);*/
                            tl = tl + parseFloat(scope.searchedArray[i].mileage);
                            tv = tv + parseFloat(scope.searchedArray[i].variableamount);
                            scope.showData.push(scope.searchedArray[i])
                        }
                    } else {
                        if (scope.model.mileageList[i]) {
                            /*scope.total = scope.total + parseFloat(scope.model.mileageList[i].mileage);
                            scope.totalvariablerate = scope.totalvariablerate + parseFloat(scope.model.mileageList[i].variableamount);*/
                            tl = tl + parseFloat(scope.model.mileageList[i].mileage);
                            tv = tv + parseFloat(scope.model.mileageList[i].variableamount);
                            scope.showData.push(scope.model.mileageList[i])
                        }
                    }
                    scope.lastIndex = i + 1;
                }

                scope.total = tl.toFixed(2);
                scope.totalvariablerate = tv.toFixed(2);
                scope.currentPage++;
            }
            scope.previous = function () {
                scope.showData = [];
                scope.total = 0;
                scope.totalvariablerate = 0;
                let tl = 0;
                let tv = 0;
                var lstInd = scope.lastIndex;
                for (var i = scope.lastIndex - (scope.itemPerPage * 2); i < lstInd - scope.itemPerPage; i++) {
                    let isSearch = scope.searchedArray.length > 0 ? true : false
                    if (isSearch) {
                        if (scope.searchedArray[i]) {
                            /*scope.total = scope.total + parseFloat(scope.model.mileageList[i].mileage);
                            scope.totalvariablerate = scope.totalvariablerate + parseFloat(scope.model.mileageList[i].variableamount);*/
                            tl = tl + parseFloat(scope.searchedArray[i].mileage);
                            tv = tv + parseFloat(scope.searchedArray[i].variableamount);
                            scope.showData.push(scope.searchedArray[i])
                        }
                    } else {
                        if (scope.model.mileageList[i]) {
                            /*scope.total = scope.total + parseFloat(scope.model.mileageList[i].mileage);
                            scope.totalvariablerate = scope.totalvariablerate + parseFloat(scope.model.mileageList[i].variableamount);*/
                            tl = tl + parseFloat(scope.model.mileageList[i].mileage);
                            tv = tv + parseFloat(scope.model.mileageList[i].variableamount);
                            scope.showData.push(scope.model.mileageList[i])
                        }
                    }
                    scope.lastIndex = i + 1;
                }
                scope.total = tl.toFixed(2);
                scope.totalvariablerate = tv.toFixed(2);
                scope.currentPage--;
            }
            scope.sortKey = 'tripdate';
            scope.sort = function (keyName) {
                //$scope.reverse = !$scope.reverse;
                scope.reverse = (scope.sortKey === keyName) ? !scope.reverse : false;
                scope.sortKey = keyName;
                if (keyName === 'mileage' || keyName === 'variableamount') {

                    scope.model.mileageList.sort(function (a, b) {
                        var nameA = parseInt(a[keyName]),
                            nameB = parseInt(b[keyName]);
                        if (scope.reverse) {
                            if (nameA < nameB) //sort string ascending
                                return -1
                            if (nameA > nameB)
                                return 1
                            return 0 //default return valuscope.model.mileageList=e (no sorting)
                        } else {
                            if (nameA < nameB) //sort string ascending
                                return 1
                            if (nameA > nameB)
                                return -1
                            return 0 //default return value (no sorting)
                        }
                    })
                }
                if (keyName === 'originname' || keyName === 'destinationname') {
                    scope.model.mileageList.sort(function (a, b) {
                        var nameA = a[keyName].toLowerCase(),
                            nameB = b[keyName].toLowerCase()
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
                if (keyName === 'tripdate' || keyName === 'submitteddate') {
                    scope.model.mileageList.sort(function (a, b) {
                        var nameA = new Date(a[keyName].toLowerCase()),
                            nameB = new Date(b[keyName].toLowerCase())
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
                scope.showData = [];
                scope.total = 0;
                scope.totalvariablerate = 0;
                let tl = 0;
                let tv = 0;
                var lstInd = scope.lastIndex;

                for (var i = scope.lastIndex - scope.itemPerPage; i < lstInd; i++) {
                    if (scope.model.mileageList[i]) {
                        tl = tl + parseFloat(scope.model.mileageList[i].mileage);
                        tv = tv + parseFloat(scope.model.mileageList[i].variableamount);
                        scope.showData.push(scope.model.mileageList[i])
                    }
                    scope.lastIndex = i + 1;
                }
                scope.total = tl.toFixed(2);
                scope.totalvariablerate = tv.toFixed(2);
            }
            scope.refreshpage = function (approvedmileageid) {

                scope.someCtrlFn({ Id: approvedmileageid });
            }
            scope.searchbarformodal = false;
            scope.callfn = function (flagstatus) {
                scope.init();
                scope.allVariableAmount = 0;
                scope.alltotalMileage = 0;
                scope.model.mileageList

                let approvedcount = 0, flagcount = 0, approvedchkcount = 0;

                if (scope.showData.length == 0) {
                    scope.checkAllShowApprove = false;
                    scope.checkAllShowFlag = false;
                    scope.displayBtn = false;
                    scope.displayDownloadBtn = false;
                }
                if (scope.showData.length > 0) {
                    scope.displayDownloadBtn = true;
                    if (scope.model.mileageList.length > 8)
                        //   scope.searchbarformodal = true;
                        scope.showmanagermodalsearchbar = true;
                    else
                        //  scope.searchbarformodal = false;
                        scope.showmanagermodalsearchbar = false;

                    scope.alltotalMileage = 0;
                    scope.allVariableAmount = 0;
                    let tv = 0;
                    let tm = 0;
                    angular.forEach(scope.model.mileageList, function (item) {
                        tv = tv + parseFloat(item.variableamount);
                        scope.allVariableAmount = tv.toFixed(2);
                        tm = tm + parseFloat(item.mileage);
                        scope.alltotalMileage = tm.toFixed(2);

                        if (item.status != 'Approved' && item.mileage > 0) {
                            approvedchkcount++;
                            scope.checkAllShowApprove = true;
                            scope.checkAllShowFlag = true;
                            if (item.isSelected) {
                                approvedcount++;
                            } else if (item.isChecked) {
                                flagcount++;
                            }
                        }
                    });
                    if (approvedchkcount == 0 && approvedcount == 0) {
                        scope.checkAllShowApprove = false;
                    }
                    else {
                        if (approvedchkcount == approvedcount) {
                            scope.IsAllChecked = true;
                            scope.IsAllCheckedFlag = false;
                        }
                    }
                    if (approvedchkcount == 0 && flagcount == 0) {
                        scope.checkAllShowFlag = false;
                    }
                    else {
                        if (approvedchkcount == flagcount) {
                            scope.IsAllCheckedFlag = true;
                            scope.IsAllChecked = false;
                        }
                    }
                    if (flagcount == 0 && approvedcount == 0)
                        scope.displayBtn = false;
                    else
                        scope.displayBtn = true;
                }
                if (flagstatus != '') {
                    scope.modalformsg({ status: flagstatus });
                }
            }
            scope.selecteddid = '';
            scope.selectedmileageidlist = [];
            scope.selectedrejectedmileageidlist = [];
            scope.displayBtn = false;
            scope.IsAllChecked = false;
            scope.IsAllCheckedFlag = false;
            scope.checkAllShowApprove = false;
            scope.checkAllShowFlag = false;
            scope.allVariableAmount = 0;
            scope.alltotalMileage = 0;

            scope.CheckUncheckAll = function () {
                scope.showData = [];
                if (scope.IsAllChecked == true)
                    scope.displayBtn = true;
                else
                    scope.displayBtn = false;

                scope.selectedmileageidlist = [];
                angular.forEach(scope.model.mileageList, function (item) {
                    item.isSelected = scope.IsAllChecked;
                    scope.selectedmileageidlist.push(item.id);
                    if (item.isChecked) {
                        item.isChecked = !item.isChecked;
                        if (scope.IsAllCheckedFlag) {
                            scope.IsAllCheckedFlag = false;
                        }
                    }
                });
                for (var i = 0; i < scope.itemPerPage; i++) {
                    scope.currentPage = 1;
                    if (scope.model.mileageList[i]) {
                        scope.showData.push(scope.model.mileageList[i])
                    }
                    scope.lastIndex = i + 1;
                }
            };
            scope.CheckUncheckHeader = function () {

                scope.selecteddid = '';
                scope.selectedmileageidlist = [];
                var total = scope.model.mileageList.length;
                var count = 0;
                var totalforshowdata = scope.showData.length;
                angular.forEach(scope.showData, function (item) {
                    if (item.isSelected) {
                        count++;
                        scope.selectedmileageidlist.push(item.id);
                        scope.selectedmonth = scope.model.clickedMonth;
                        scope.selecteddid = item.driverid;
                        if (item.isChecked) {
                            item.isChecked = !item.isChecked;
                        }
                    }
                });
                if (total == count && (total == totalforshowdata && (total != 0 && totalforshowdata != 0))) {
                    scope.model.mileageList = scope.showData;
                    scope.IsAllChecked = true;
                    scope.IsAllCheckedFlag = false;
                }
                else {
                    scope.IsAllChecked = false;
                    scope.IsAllCheckedFlag = false;
                }

                var trues = $filter("filter")(scope.showData, { isChecked: true });
                scope.chkselectcount = trues.length;
                if (count == 0 && scope.chkselectcount == 0) {
                    scope.displayBtn = false;
                }
                else {
                    scope.displayBtn = true;
                }
            };
            scope.CheckUncheckAllForFlag = function () {
                scope.showData = [];
                if (scope.IsAllCheckedFlag == true)
                    scope.displayBtn = true;
                else
                    scope.displayBtn = false;
                scope.selectedrejectedmileageidlist = [];
                scope.model.mileageList
                scope.showData

                angular.forEach(scope.model.mileageList, function (item) {
                    if (item.isChecked) {
                        scope.selectedmonth = scope.model.clickedMonth;
                    }
                    item.isChecked = scope.IsAllCheckedFlag;
                    scope.selectedrejectedmileageidlist.push(item.id);
                    if (item.isSelected) {

                        item.isSelected = !item.isSelected;
                        if (scope.IsAllChecked) {
                            scope.IsAllChecked = false;
                        }
                    }
                });
                for (var i = 0; i < scope.itemPerPage; i++) {
                    scope.currentPage = 1;
                    if (scope.model.mileageList[i]) {
                        scope.showData.push(scope.model.mileageList[i])
                    }
                    scope.lastIndex = i + 1;
                }
                scope.showData
            };

            scope.CheckUncheckHeaderForFlag = function (index) {

                scope.selecteddid = '';

                scope.selectedrejectedmileageidlist = [];
                var total = scope.model.mileageList.length;
                var count = 0;
                var totalforshowdata = scope.showData.length;
                scope.showData

                angular.forEach(scope.showData, function (item) {
                    if (item.isChecked) {
                        count++;
                        scope.selecteddid = item.driverid;
                        scope.selectedmonth = scope.model.clickedMonth;
                        scope.selectedmileageid = item.id;
                        scope.selectedrejectedmileageidlist.push(item.id);
                        if (item.isSelected) {
                            item.isSelected = !item.isSelected;
                        }
                    }
                });

                if (total == count && (total == totalforshowdata && (total != 0 && totalforshowdata != 0))) {
                    scope.model.mileageList = scope.showData;
                    scope.IsAllCheckedFlag = true;
                    scope.IsAllChecked = false;
                }
                else {
                    scope.IsAllCheckedFlag = false;
                    scope.IsAllChecked = false;
                }
                var trues = $filter("filter")(scope.showData, { isSelected: true });
                scope.chkselectcount = trues.length;
                if (count == 0 && scope.chkselectcount == 0)
                    scope.displayBtn = false;
                else
                    scope.displayBtn = true;
                scope.showData
            };
            scope.refreshpage = function (mileages) {

                scope.someCtrlFn({ Id: mileages });
            }

            scope.updatePagination = function () {
                if (scope.search.length > 0) {
                    scope.itemPerPage = 8;

                    var filteredArray = scope.model.mileageList.filter(function (number) {
                        if (number.originname != '' && number.originname != null && number.originname != undefined) {
                            return number.originname.toLowerCase().indexOf(scope.search.toLowerCase()) !== -1 || number.destinationname.toLowerCase().indexOf(scope.search.toLowerCase()) !== -1;
                        }
                        return number.originname;
                    });

                    scope.searchedArray = filteredArray;
                    scope.showData = [];
                    scope.total = 0.0;
                    scope.totalvariablerate = 0.0;
                    scope.maxPage = 0;
                    scope.totalRecords = filteredArray.length;

                    let tl = 0;
                    let tv = 0;
                    scope.maxPage = Math.ceil(scope.totalRecords / scope.itemPerPage)
                    scope.totalRecords
                    for (var i = 0; i < scope.itemPerPage; i++) {
                        scope.currentPage = 1;
                        if (filteredArray[i]) {
                            /*scope.total = scope.total + parseFloat(scope.model.mileageList[i].mileage);*/
                            tl = tl + parseFloat(filteredArray[i].mileage);
                            tv = tv + parseFloat(filteredArray[i].variableamount);
                            /*scope.totalvariablerate = scope.totalvariablerate + parseFloat(scope.model.mileageList[i].variableamount);*/
                            scope.showData.push(filteredArray[i])
                        }
                        scope.lastIndex = i + 1;
                    }
                    scope.total = tl.toFixed(2);
                    scope.totalvariablerate = tv.toFixed(2);


                } else {
                    scope.itemPerPage = 8;
                    scope.init();
                }


            }
            element.on('shown.bs.modal', function () {
                scope.$apply(function () {
                    scope.model.visible = true;

                });
            });

            element.on('hidden.bs.modal', function () {
                scope.$apply(function () {
                    scope.model.visible = false;
                    scope.search = "";
                    scope.searchedArray.length = 0;
                });
            });

            $('input[type=search]').on('search', function () {
                scope.search = "";
                scope.searchedArray.length = 0;
            });

            scope.onClick = function () {
                scope.model.mileageList
                scope.updateformileagelist = [];
                $('#spinner').show();
                var arr = [];
                if (scope.IsAllChecked || scope.IsAllCheckedFlag) {
                    arr = scope.model.mileageList;
                } else {
                    arr = scope.showData;
                }
                angular.forEach(arr, function (item) {
                    if (item.isChecked == true || item.isSelected == true) {
                        scope.updateformileagelist.push(item);
                    }
                });
                var truecheck = $filter("filter")(arr, { isChecked: true });
                scope.chkcount = truecheck.length;
                var trueselect = $filter("filter")(arr, { isSelected: true });
                scope.selectcount = trueselect.length;
                Visualforce.remoting.Manager.invokeAction(
                    '{!$RemoteAction.AdminDashboardController.approveMileages}', JSON.stringify(truecheck), JSON.stringify(trueselect),
                    function (result, event) {
                        if (event.status && result == 'success') {
                            scope.model.mileageList
                            var tempArray = JSON.parse(JSON.stringify(scope.model.mileageList));
                         
                            scope.model.mileageList.forEach(function (item) {
                                for (var i = 0; i < scope.updateformileagelist.length; i++) {
                                    if (item.reimbursementid == scope.updateformileagelist[i].reimbursementid) {
                                        let tp = 0;
                                        tp = parseFloat(item.totalpending);
                                        tp = tp - parseFloat(scope.updateformileagelist[i].mileage);
                                        item.totalpending = tp.toFixed(2);
                                     
                                    }
                                }
                            })

                            if (tempArray.length !== scope.updateformileagelist.length) {
                                tempArray.forEach(function (item) {
                                    scope.updateformileagelist.forEach(function (ui) {
                                        if (item.id == ui.id) {
                                            let index = scope.model.mileageList.findIndex(x => x.id === ui.id);
                                            scope.model.mileageList.splice(index, 1);
                                        }
                                    })
                                })
                            } else {
                                scope.model.mileageList = [];
                            }
                            var flagstatus = '';

                            if (scope.selectcount > 0 && scope.selectedmileageidlist.length > 0) {
                                flagstatus = flagstatus + 'true';
                                scope.refreshpage(scope.selectedmileageidlist);
                                scope.selectedmileageidlist = [];
                            }
                            if (scope.chkcount > 0 && scope.selectedrejectedmileageidlist.length > 0) {
                                flagstatus = flagstatus + 'false';
                                scope.refreshpage(scope.selectedrejectedmileageidlist);
                                scope.selectedrejectedmileageidlist = [];
                            }
                            scope.callfn(flagstatus);
                        }
                        else {
                            toastr.error('Something went wrong');
                        }
                    });
            };
        },
        template: '<div class="modal fade driver-dashboard-monthrecord show in" tabindex="-1" role="dialog"aria-labelledby="driver-dashboard-monthrecord" id="driver-dashboard-monthrecord"><div class="modal-dialog modal-xl modal-dialog-centered"><div class="modal-content rounded-0"><button type="button" ng-click="cancel()" class="close popup-close-btn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button><div class="modal-body"><h4 ng-model="month">{{model.name}}</h4><div class="modal-divider"></div><div class="table-responsive"><div id="example_filter" class="dataTables_filter pull-right d-block" ng-show="showmanagermodalsearchbar"><div class="input-group w-85" ><i id="filtericon" class="fa fa-search" ng-if="search.length===0"></i><input class="form-control py-2 border-right-0 border" type="search" ng-model="search" ng-change="updatePagination()" placeholder="Search..." aria-controls="example" id="example-search-input" /></div></div><table id="driver-dashbord-month-model" class="table table-striped dt-responsive nowrap no-footer dataTable" cellspacing="0" width="100%"><thead><tr><th ng-click="sort(\'tripdate\')">Trip Date<span ng-show="sortKey == \'tripdate\'" class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'originname\')">Origin<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}" ng-show="sortKey == \'origin\'"></span></th><th ng-click="sort(\'destinationname\')">Dest.<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}" ng-show="sortKey == \'destinationname\'"></span></th><th ng-click="sort(\'submitteddate\')">Submitted<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}" ng-show="sortKey == \'submitteddate\'"></span></th><th ng-click="sort(\'approveddate\')">Approved<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}" ng-show="sortKey == \'approveddate\'"></span></th><th ng-click="sort(\'mileage\')">Mileage<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}" ng-show="sortKey == \'mileage\'"></span></th><th ng-click="sort(\'variableamount\')">Variable Amount<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}" ng-show="sortKey == \'variableamount\'"></span></th><th><button class="btn btn-primary pull-right">Approve <input type="checkbox" ng-click="CheckUncheckAll()" ng-model="IsAllChecked" ng-show="checkAllShowApprove"/></button></th><th class="vw-4"><button class="btn btn-third pull-right">Flag </span><input type="checkbox" ng-show="checkAllShowFlag" ng-click="CheckUncheckAllForFlag()" ng-model="IsAllCheckedFlag"></button></th></tr></thead><tbody class="table-a-link"><tr ng-repeat="mil in showData |itemsPerPage:itemPerPage|filter:search" current-page:"currentPage"><td ng-model="mil.tripdate">{{ mil.tripdate}}</td><td ng-model="mil.originname">{{ mil.originname}}</td><td ng-model="mil.destinationname">{{ mil.destinationname }}</td><td ng-model="mil.submitteddate">{{ mil.submitteddate }}</td><td ng-model="mil.approveddate">{{mil.approveddate }}</td><td ng-model="mil.mileage">{{ mil.mileage }}</td><td ng-model="mil.variableamount" id="modalvariableid">${{ mil.variableamount }}</td><td ng-model="mil.status"><div ng-model="mil.status" ng-if="mil.status !=\'Approved\' && mil.mileage > \'0\'"></div><div class="mr-11 pull-right" ng-if="mil.status !=\'Approved\' && mil.mileage > \'0\'"><input type="checkbox" ng-model="mil.isSelected" ng-click="CheckUncheckHeader();"></div></td><td ng-model="mil.status" class="mr-11 pull-right"><div ng-model="mil.status" ng-if="mil.mileage > \'0\'"></div><div class="mr-1 pull-right" ng-if="mil.mileage > \'0\'"><input type="checkbox" ng-model="mil.isChecked" class="flagcheck" ng-click="CheckUncheckHeaderForFlag();"></div></td></tr></tbody><tfoot><tr><th scope="row">Total</th><th colspan="4"> </th><th>{{total}} / {{alltotalMileage}}</th><th>${{totalvariablerate}} / ${{allVariableAmount}}</th><th colspan="2"></th></tr></tfoot></table></div></div><div class="modal-footer"><div class="col-md-6" ng-if="displayDownloadBtn">{{currentPage}} of {{maxPage}} Page</div><div class="col-md-6"><ul ng-if="displayDownloadBtn" class="pagination pull-right paginationformodal"><li class="page-item " ng-class="{\'disable-pagination\':currentPage === 1}"><a class="page-link" ng-click="previous()">Previous</a></li><li class="page-item"><a class="page-link" >{{currentPage}}</a></li><li class="page-item" ng-class="{\'disable-pagination\':currentPage === maxPage}"><a class="page-link" ng-click="next()" href="#">Next</a></li></ul><div class="paginationformodaldownloadbutton"><div excel-export="true" export-data="data()" ng-show="displayDownloadBtn" file-name="{{model.fileName}}"/><button class="btn btn-secondary float-right" ng-click="onClick();" ng-show="displayBtn">Submit</button></div></div></div></div></div></div><div>'
    };
}
]);


//Excel Export Directive
app.directive('excelExport', function () {
return {
    restrict: 'A',
    scope: {
        fileName: "@",
        data: "&exportData"
    },
    replace: true,
    template: '<button class="btn btn-primary float-right mr-11" ng-click="download()">Download <i class="fa fa-download"></i></button>',
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
        template: '<div class="modal fade show in" tabindex="-1" role="dialog" aria-labelledby="driver-dashboard-monthrecord" id="driver-dashboard-monthrecord"><div class="modal-dialog modal-xl modal-dialog-centered"><div class="modal-content rounded-0"><button type="button" class="close popup-close-btn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button><div class="modal-body"><h4>Manager List</h4><div class="modal-divider"></div><div class="table-responsive"><div id="example_filter" class="dataTables_filter pull-right d-block" ng-show="showmanagermodalsearchbar"><div class="input-group w-85" ><i id="filtericon" class="fa fa-search" ng-if="search.length===0"></i><input class="form-control py-2 border-right-0 border" type="search" ng-model="search" ng-change="updatePagination()" placeholder="Search..." aria-controls="example" id="example-search-input1" /></div></div><table id="driver-dashbord-month-model" class="table table-striped dt-responsive nowrap dataTable no-footer" cellspacing="0" width="100%"><thead><tr><th ng-click="sortBy1(\'Name\')">Manager Name<span ng-show="sortKey1 == \'Name\'" class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sortBy1(\'Email\')">Email<span class="sort-icon pull-right" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}" ng-show="sortKey1 == \'Email\'"></span></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="manager in model.managerList | orderBy:sortKey1:reverse1|filter:search|itemsPerPage:pageSize" current-page="currentPage"><td><a href="/app/managerdashboardfromadmin?managerid={{manager.Id}}&accid={{manager.AccountId}}&id={{model.aid}}&showteam={{model.showteam}}">{{ manager.Name }}</a></td><td><a href="mailto:{{ manager.Email}}" target="_blank">mailto:{{ manager.Email}}</a></td></tr></tbody></table><dir-pagination-controls max-size="5"  direction-links="true" boundary-links="true" auto-hide ="true" responsive="true" class="pull-right"></dir-pagination-controls></div></div><div class="modal-footer"><div excel-export="true" export-data="data()" file-name="{{model.filename}}"/></div></div></div></div></div>'
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
                //$scope.reverse = !$scope.reverse;

                scope.reverse = ($scope.sortKey === keyname) ? !$scope.reverse : false;
                scope.sortKey = keyname;
                if (keyname === 'totalMileages') {
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
        template: '<table id="admindriver-dashboard" class="table table-striped dt-responsive nowrap dataTable textalign-c" cellspacing="0" width="100%"><thead><tr><th id="name" ng-click="sort(\'name\')">Name <span class="sort-icon pull-right" ng-show="sortKey==\'name\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'threshold\')">Approval <br/>Threshold <span class="sort-icon pull-right" ng-show="sortKey==\'threshold\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"> </span></th><th ng-click="sort(\'totalMileages\')">Submitted <br/>Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'totalMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'rejectedMileages\')">Flagged <br/>Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'rejectedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'approvedMileages\')">Approved <br/>Mileage <span class="sort-icon pull-right" ng-show="sortKey==\'approvedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span></th><th ng-click="sort(\'approvedDate\')" class="approvedDateth"> <span class="sort-icon pull-right" ng-show="sortKey==\'approvedDate\'" ng-class="{\'fa fa-chevron-up\':reverse,\'fa fa-chevron-down\':!reverse}"></span><div ng-if="displayApprovebtn" class="btn btn-primary-approve"> <span class="appspan">Approve</span> <input type="checkbox" class="approvechk" ng-model="checkboxObj.IsAllCheckedForApprove" ng-click="myTeamCheckUncheckAll(checkboxObj.IsAllCheckedForApprove)" /></div></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="LastMonthReimbursement in AllDriversLastMonthReimbursements|filter:search|itemsPerPage:pageSize" current-page="currentPage" ng-model="LastMonthReimbursement"><td ng-model="LastMonthReimbursement.name"> <a href="/app/driverdashboardfromadminmanager?accid={{accid}}&id={{LastMonthReimbursement.contactid}}&adminid={{aid}}&showteam={{showteam}}">{{LastMonthReimbursement.name}} </a></td><td ng-model="LastMonthReimbursement.threshold"> <input type="text" ng-change="showbtn(LastMonthReimbursement.contactid,LastMonthReimbursement.threshold)" ng-model="LastMonthReimbursement.threshold" id="numberinput" class="numinputedit form-control rounded-0 col-md-6" value="{{LastMonthReimbursement.threshold | number:2}}" /></td><td ng-model="LastMonthReimbursement.totalMileages"> {{LastMonthReimbursement.totalMileages | number:2}}</td><td ng-model="LastMonthReimbursement.totalMileages"> {{LastMonthReimbursement.rejectedMileages | number:2}}</td><td ng-model="LastMonthReimbursement.approvedMileages"> {{LastMonthReimbursement.approvedMileages | number:2}}</td><td><div class="statusapprove" ng-model="LastMonthReimbursement.status" ng-if="LastMonthReimbursement.status!=\'Pending\' && LastMonthReimbursement.totalMileages > \'0.00\'"> {{LastMonthReimbursement.status}} on {{LastMonthReimbursement.approvedDate}}</div><div ng-if="LastMonthReimbursement.status ==\'Pending\' && LastMonthReimbursement.totalMileages > \'0.00\'"> <input type="checkbox" ng-model="LastMonthReimbursement.isSelected" ng-click="CheckUncheckHeader(LastMonthReimbursement.status)" class="myteamcheck" /></div></td></tr><tr ng-if="lengthformyteam == 0"><td colspan="6" class="table-nodata">No Mileage Available</td></tr></tbody></table>  <div ng-if="lengthformyteam > 30"><dir-pagination-controls max-size="1" direction-links="true" boundary-links="true" responsive="true" auto-hide="false" class="pull-right"></dir-pagination-controls></div>'
    };
}]);


app.directive('unapprovemileageTableDirective',[function(){
     return{
         restrict: 'E',
         link: function(scope){
             //Sorting For table of all Un Approved Reimburesment
             scope.sortKey1 = 'Name';   //set the sortKey to the param passed   
             scope.reverse1 = false;
             scope.sort1 = function (keyname) {
                 scope.sortKey1 = keyname;   //set the sortKey to the param passed
                 scope.reverse1 = !$scope.reverse1; //if true make it false and vice versa
             }
         },
         template:'<table id="admindriver-mileage-dashboard" class="table table-striped dt-responsive nowrap dataTable textalign-c" cellspacing="0" width="100%"><thead><tr><th id="nameforunapprove" ng-click="sort1(\'name\')">Name <span class="sort-icon pull-right" ng-show="sortKey1==\'name\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sort1(\'threshold\')">Approval<br/> Threshold <span class="sort-icon pull-right" ng-show="sortKey1==\'threshold\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"> </span></th><th ng-click="sort1(\'totalMileages\')">Unpproved<br/> Mileage <span class="sort-icon pull-right" ng-show="sortKey1==\'totalMileages\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sort1(\'approvedMileages\')">Approved<br/> Mileage <span class="sort-icon pull-right" ng-show="sortKey1==\'approvedMileages\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th ng-click="sort1(\'name\')">Approving<br/>Manager <span class="sort-icon pull-right" ng-show="sortKey1== \'name\'" ng-class="{\'fa fa-chevron-up\':reverse1,\'fa fa-chevron-down\':!reverse1}"></span></th><th class="emailth"> <button class="btn btn-secondary pull-right w-68 plt-0" ng-if="displayEmailReminder"><span class="emailspan">Email</span><br/><span>Reminder</span>&nbsp;<input ng-show="checkAllShowForUnApprove" class="emailchk" type="checkbox" ng-model="checkboxObj.IsAllEmailCheckedForUnapprove" ng-click="unApprovedEmailCheckUncheckAll(checkboxObj.IsAllEmailCheckedForUnapprove)" /></button></th><th class="approveth"> <button class="btn btn-primary-approve" ng-if="displayApprovebtn"><span class="appspan">Approve</span><input ng-show="checkAllShowForUnApprove" class="approvechk" type="checkbox" ng-model="checkboxObj.IsAllCheckedForUnapprove" ng-click="unApprovedCheckUncheckAll(checkboxObj.IsAllCheckedForUnapprove)" /></button></th></tr></thead><tbody class="table-a-link"><tr dir-paginate="UnapprovedReimburesement in AllDriversLastMonthUnapprovedReimbursementsClone |filter:search1|itemsPerPage:pageSize" current-page="currentPage" ng-model="UnapprovedReimburesement"><td ng-model="UnapprovedReimburesement.name" > <a ng-click="openmodalForunapprovedata(UnapprovedReimburesement.name,UnapprovedReimburesement.contactid,UnapprovedReimburesement,UnapprovedReimburesement.managerName)">{{UnapprovedReimburesement.name}} </a></td><td ng-model="UnapprovedReimburesement.threshold" > {{UnapprovedReimburesement.threshold | number:2 }}</td><td ng-model="UnapprovedReimburesement.totalMileages" > {{UnapprovedReimburesement.totalMileages | number:2 }}</td><td ng-model="UnapprovedReimburesement.approvedMileages" > {{UnapprovedReimburesement.approvedMileages | number:2 }}</td><td ng-model="UnapprovedReimburesement.name" > <a ng-click="openmodalForunapprovedata(UnapprovedReimburesement.name,UnapprovedReimburesement.contactid,UnapprovedReimburesement.mileagesList,UnapprovedReimburesement.managerName)">{{UnapprovedReimburesement.managerName}} </a></td><td ng-model="UnapprovedReimburesement.status" ><div ng-model="UnapprovedReimburesement.status" ng-if="UnapprovedReimburesement.status==\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\'"></div><div> <input type="checkbox" ng-model="UnapprovedReimburesement.isSelectedEmailReminder" ng-change="CheckUncheckHeaderUnapproveForEmail()" class="upapprovechk mr-6" /></div></td><td ng-model="UnapprovedReimburesement.status" ><div class="statusapprove" ng-model="UnapprovedReimburesement.status" ng-if="UnapprovedReimburesement.status==\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\'"> {{UnapprovedReimburesement.status}} on {{UnapprovedReimburesement.approvedDate}}</div><div ng-if="UnapprovedReimburesement.status !=\'Approved\' && UnapprovedReimburesement.totalMileages > \'0.00\'"> <input type="checkbox" ng-model="UnapprovedReimburesement.isSelected" ng-change="CheckUncheckHeaderUnapprove()" class="upapprovecheck" /></div></td></tr><tr ng-if="lengthforunapprovebtndisable == 0"><td colspan="5" class="table-nodata">No Mileage Available</td></tr></tbody></table><div><dir-pagination-controls max-size="1" direction-links="true" boundary-links="true" responsive="true" auto-hide="false" class="pull-right"></dir-pagination-controls></div>'
     }
}]);