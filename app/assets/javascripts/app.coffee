#=require jquery
#=require_self
#=require bootstrap

$ ->

    angular.module('App', ['ngRoute'])

        .config([
            '$routeProvider', '$locationProvider',
            ($routeProvider, $locationProvider) ->
                true
        ])

        .controller('App.views.main', [
            '$scope', 'App.services.sets', 'App.services.properties'
            ($scope, sets, properties) ->

                $scope.main = {
                    model: {
                        properties: [],
                        sets: [],
                        selectedSet: null,
                        selectedProperties: null
                    }
                }

                sets.list().then (response) ->
                    $scope.main.model.sets = response.data

                properties.list().then (response) ->
                    $scope.main.model.properties = response.data

                true
        ])

        .factory('App.services.sets', [
            '$http', '$timeout', '$q',
            ($http, $timeout, $q) ->
                new ->
                    @blank = ->
                        {}

                    @list = ->
                        q = $q.defer()
                        $timeout (->
                            q.resolve data: [
                                {
                                    id: 0
                                    name: "Portfolio 1"
                                    properties: [
                                        {
                                            id: 0
                                            name: "Property 1"
                                        },
                                        {
                                            id: 1
                                            name: "Property 2"
                                        }
                                    ]
                                }
                            ]
                        ), 200
                        q.promise

                    true
        ])

        .factory('App.services.properties', [
            '$http', '$timeout', '$q',
            ($http, $timeout, $q) ->
                new ->
                    @blank = ->
                        {}

                    @list = ->
                        q = $q.defer()
                        $timeout (->
                            q.resolve data: [
                                {
                                    id: 0
                                    name: "Property 1"
                                },
                                {
                                    id: 1
                                    name: "Property 2"
                                },
                                {
                                    id: 2
                                    name: "Property 3"
                                },
                                {
                                    id: 3
                                    name: "Property 4"
                                }
                            ]
                        ), 200
                        q.promise

                    true
        ])

        .directive('sets', [
            '$timeout', '$filter',
            ($timeout, $filter) ->
                {
                    templateUrl: '/templates/sets.html',
                    scope: {
                        sets: '=',
                        properties: '=',
                        selectedSet: '=',
                        selectedProperties: '='
                    },
                    link: ($scope, element, attrs) ->

                        newSet = {
                            id: null,
                            name: null,
                            properties: null
                        }

                        newProperty = {
                            id: null,
                            name: null
                        }

                        $scope.model = {
                            newSet: angular.copy(newSet),
                            newProperty: angular.copy(newProperty)
                        }

                        $scope.selectAll = ->
                            properties = $filter('search')($scope.properties, 'name', $scope.model.searchText)
                            angular.forEach properties, (val) ->
                                val.selected = true
                            $scope.updateSelected()

                        $scope.deselectAll = ->
                            angular.forEach $scope.properties, (val) ->
                                val.selected = false
                            $scope.updateSelected()

                        $scope.deletePropertyFromSet = (set, property) ->
                            set.properties.splice set.properties.indexOf(property), 1

                        $scope.deleteProperty = (property) ->
                            $scope.properties.splice $scope.properties.indexOf(property), 1
                            $scope.updateSelected()

                        $scope.createPropertyInSet = (set) ->
                            property = $scope.createProperty()
                            set.properties.push property

                        $scope.createProperty = ->
                            property = angular.copy($scope.model.newProperty)
                            property.selected = true
                            $scope.properties.push property  if property.name
                            $scope.model.newProperty = angular.copy(newProperty)
                            $scope.updateSelected()
                            property

                        $scope.createSet = ->
                            set = angular.copy($scope.model.newSet)
                            properties = []
                            angular.forEach $scope.properties, (val) ->
                                properties.push val  if val.selected

                            set.id = Math.round(Math.random() * 1000000)
                            set.properties = properties
                            if set.name and set.properties.length
                                $scope.sets.unshift set
                                $scope.model.newSet = angular.copy(newSet)
                                $timeout (->
                                    $scope.show set
                                ), 100

                        $scope.updateSelected = ->
                            properties = []
                            angular.forEach $scope.properties, (val) ->
                                properties.push val  if val.selected

                            $scope.selectedProperties = properties
                        
                        $scope.deleteSet = (set) ->
                            $scope.sets.splice $scope.sets.indexOf(set), 1

                        $scope.show = (idOrSet) ->
                            element.find(".panel-collapse.in").collapse "hide"
                            if typeof idOrSet is "string"
                                $("#" + idOrSet).collapse "show"
                                $scope.selectedSet = null
                            else
                                $("#set-" + idOrSet.id).collapse "show"
                                $scope.selectedSet = idOrSet

                }
        ])

        .filter("search", ->
            (objects, fieldName, searchText) ->
                return objects  if objects is `undefined` or objects.length is 0
                return objects  if searchText is `undefined` or searchText.length is 0
                retval = []
                angular.forEach objects, (o) ->
                    terms = searchText.toLowerCase().split(" ")
                    found = 0
                    str = (if o[fieldName] then o[fieldName] else "")
                    str = str.toLowerCase()
                    console.log str, terms
                    angular.forEach terms, (e) ->
                        found++ if str.indexOf(e) > -1
                    retval.push o if found is terms.length
                retval
        )
